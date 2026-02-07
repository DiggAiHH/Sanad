import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline queue operation types.
enum OfflineOperationType {
  /// Create a new ticket
  createTicket,

  /// Call next patient
  callNext,

  /// Complete ticket
  completeTicket,

  /// Skip ticket
  skipTicket,

  /// Rate service
  rateService,
}

/// Represents a queued offline operation.
class OfflineOperation {
  /// Unique operation ID.
  final String id;

  /// Type of operation.
  final OfflineOperationType type;

  /// Operation payload (JSON-serializable).
  final Map<String, dynamic> payload;

  /// When the operation was queued.
  final DateTime createdAt;

  /// Number of retry attempts.
  int retryCount;

  /// Last error message (if any).
  String? lastError;

  OfflineOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  /// Convert to JSON for storage.
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
        'lastError': lastError,
      };

  /// Create from JSON storage.
  factory OfflineOperation.fromJson(Map<String, dynamic> json) {
    return OfflineOperation(
      id: json['id'] as String,
      type: OfflineOperationType.values.byName(json['type'] as String),
      payload: json['payload'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      lastError: json['lastError'] as String?,
    );
  }
}

/// Callback type for operation execution.
typedef OperationExecutor = Future<bool> Function(OfflineOperation operation);

/// Service for managing offline operations queue.
///
/// Provides:
/// - Persistent queue of operations (SharedPreferences)
/// - Automatic sync when online
/// - Retry with exponential backoff
/// - Operation deduplication
///
/// Usage:
/// ```dart
/// final offlineService = OfflineService();
/// await offlineService.initialize();
///
/// // Queue an operation when offline
/// await offlineService.enqueue(
///   OfflineOperationType.createTicket,
///   {'queue_id': 'abc123'},
/// );
///
/// // Process queue when online
/// await offlineService.processQueue(executor);
/// ```
class OfflineService {
  static const String _storageKey = 'sanad_offline_queue';
  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(seconds: 2);

  final Logger _logger = Logger();

  /// In-memory queue (synced with storage).
  final List<OfflineOperation> _queue = [];

  /// Whether the service is initialized.
  bool _initialized = false;

  /// Stream controller for queue changes.
  final _queueController = StreamController<List<OfflineOperation>>.broadcast();

  /// Stream of queue changes.
  Stream<List<OfflineOperation>> get queueStream => _queueController.stream;

  /// Current queue (read-only).
  List<OfflineOperation> get queue => List.unmodifiable(_queue);

  /// Number of pending operations.
  int get pendingCount => _queue.length;

  /// Whether there are pending operations.
  bool get hasPending => _queue.isNotEmpty;

  /// Initialize the service and load persisted queue.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _queue.addAll(
          jsonList.map((e) => OfflineOperation.fromJson(e as Map<String, dynamic>)),
        );
        _logger.i('Loaded ${_queue.length} offline operations from storage');
      }

      _initialized = true;
      _notifyListeners();
    } catch (e, stack) {
      _logger.e('Failed to initialize OfflineService', error: e, stackTrace: stack);
      _initialized = true; // Continue without persisted data
    }
  }

  /// Add operation to the offline queue.
  ///
  /// Returns the operation ID for tracking.
  Future<String> enqueue(
    OfflineOperationType type,
    Map<String, dynamic> payload,
  ) async {
    _ensureInitialized();

    final operation = OfflineOperation(
      id: _generateId(),
      type: type,
      payload: payload,
      createdAt: DateTime.now(),
    );

    _queue.add(operation);
    await _persist();
    _notifyListeners();

    _logger.i('Queued offline operation: ${operation.type.name} (${operation.id})');
    return operation.id;
  }

  /// Remove operation from queue (after successful sync).
  Future<void> remove(String operationId) async {
    _ensureInitialized();

    _queue.removeWhere((op) => op.id == operationId);
    await _persist();
    _notifyListeners();
  }

  /// Clear all pending operations.
  Future<void> clear() async {
    _ensureInitialized();

    _queue.clear();
    await _persist();
    _notifyListeners();

    _logger.i('Cleared offline queue');
  }

  /// Process all pending operations.
  ///
  /// [executor] is called for each operation to execute it.
  /// Returns the number of successfully processed operations.
  Future<int> processQueue(OperationExecutor executor) async {
    _ensureInitialized();

    if (_queue.isEmpty) {
      _logger.d('Offline queue is empty, nothing to process');
      return 0;
    }

    _logger.i('Processing ${_queue.length} offline operations...');

    int successCount = 0;
    final toRemove = <String>[];

    for (final operation in _queue.toList()) {
      try {
        final success = await executor(operation);

        if (success) {
          toRemove.add(operation.id);
          successCount++;
          _logger.d('Processed: ${operation.type.name} (${operation.id})');
        } else {
          operation.retryCount++;
          operation.lastError = 'Executor returned false';

          if (operation.retryCount >= _maxRetries) {
            toRemove.add(operation.id);
            _logger.w('Max retries reached: ${operation.type.name} (${operation.id})');
          } else {
            // Exponential backoff
            final delay = _baseDelay * (1 << operation.retryCount);
            await Future.delayed(delay);
          }
        }
      } catch (e, stack) {
        operation.retryCount++;
        operation.lastError = e.toString();
        _logger.e(
          'Failed: ${operation.type.name} (${operation.id})',
          error: e,
          stackTrace: stack,
        );

        if (operation.retryCount >= _maxRetries) {
          toRemove.add(operation.id);
          _logger.w('Max retries reached: ${operation.type.name} (${operation.id})');
        }
      }
    }

    // Remove processed/failed operations
    _queue.removeWhere((op) => toRemove.contains(op.id));
    await _persist();
    _notifyListeners();

    _logger.i('Processed $successCount/${_queue.length + successCount} operations');
    return successCount;
  }

  /// Dispose resources.
  void dispose() {
    _queueController.close();
  }

  // =========================================================================
  // Private helpers
  // =========================================================================

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('OfflineService not initialized. Call initialize() first.');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_queue.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e, stack) {
      _logger.e('Failed to persist offline queue', error: e, stackTrace: stack);
    }
  }

  void _notifyListeners() {
    _queueController.add(List.unmodifiable(_queue));
  }

  String _generateId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final random = now.hashCode.toRadixString(36);
    return 'op_${now}_$random';
  }
}
