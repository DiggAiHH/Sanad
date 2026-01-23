import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

/// Offline-Sync Manager
/// 
/// Ermöglicht Offline-First Funktionalität:
/// - Daten lokal cachen
/// - Änderungen queuen bei Offline
/// - Automatisch synchronisieren bei Online
class OfflineSyncManager {
  static OfflineSyncManager? _instance;
  static OfflineSyncManager get instance => _instance ??= OfflineSyncManager._();
  
  OfflineSyncManager._();
  
  late Box<Map> _syncQueueBox;
  late Box<Map> _cacheBox;
  
  bool _isOnline = true;
  final _onlineController = StreamController<bool>.broadcast();
  
  Stream<bool> get onlineStream => _onlineController.stream;
  bool get isOnline => _isOnline;
  
  /// Initialisiert Hive für Offline-Storage
  Future<void> init() async {
    await Hive.initFlutter();
    _syncQueueBox = await Hive.openBox<Map>('sync_queue');
    _cacheBox = await Hive.openBox<Map>('data_cache');
    
    debugPrint('OfflineSyncManager initialized');
    debugPrint('Pending sync items: ${_syncQueueBox.length}');
  }
  
  /// Setzt Online-Status
  void setOnlineStatus(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      _onlineController.add(online);
      
      if (online) {
        // Trigger sync when coming back online
        syncPendingChanges();
      }
    }
  }
  
  // =========================================================================
  // CACHE OPERATIONS
  // =========================================================================
  
  /// Speichert Daten im lokalen Cache
  Future<void> cacheData(String key, Map<String, dynamic> data) async {
    await _cacheBox.put(key, {
      'data': data,
      'cachedAt': DateTime.now().toIso8601String(),
    });
  }
  
  /// Holt Daten aus dem Cache
  Map<String, dynamic>? getCachedData(String key) {
    final cached = _cacheBox.get(key);
    if (cached == null) return null;
    return Map<String, dynamic>.from(cached['data'] as Map);
  }
  
  /// Prüft ob Cache noch gültig ist
  bool isCacheValid(String key, {Duration maxAge = const Duration(hours: 1)}) {
    final cached = _cacheBox.get(key);
    if (cached == null) return false;
    
    final cachedAt = DateTime.parse(cached['cachedAt'] as String);
    return DateTime.now().difference(cachedAt) < maxAge;
  }
  
  /// Löscht Cache für einen Key
  Future<void> clearCache(String key) async {
    await _cacheBox.delete(key);
  }
  
  /// Löscht gesamten Cache
  Future<void> clearAllCache() async {
    await _cacheBox.clear();
  }
  
  // =========================================================================
  // SYNC QUEUE OPERATIONS
  // =========================================================================
  
  /// Fügt Änderung zur Sync-Queue hinzu (für Offline-Modus)
  Future<void> queueChange(SyncOperation operation) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    await _syncQueueBox.put(id, {
      'id': id,
      'type': operation.type.name,
      'endpoint': operation.endpoint,
      'method': operation.method,
      'data': operation.data,
      'createdAt': DateTime.now().toIso8601String(),
      'retryCount': 0,
    });
    
    debugPrint('Queued offline change: ${operation.type} - ${operation.endpoint}');
  }
  
  /// Holt alle ausstehenden Sync-Operationen
  List<SyncOperation> getPendingOperations() {
    return _syncQueueBox.values.map((item) {
      final map = Map<String, dynamic>.from(item);
      return SyncOperation(
        id: map['id'] as String,
        type: SyncOperationType.values.firstWhere(
          (e) => e.name == map['type'],
        ),
        endpoint: map['endpoint'] as String,
        method: map['method'] as String,
        data: Map<String, dynamic>.from(map['data'] as Map),
        createdAt: DateTime.parse(map['createdAt'] as String),
        retryCount: map['retryCount'] as int,
      );
    }).toList();
  }
  
  /// Synchronisiert alle ausstehenden Änderungen
  Future<SyncResult> syncPendingChanges() async {
    if (!_isOnline) {
      return SyncResult(success: false, message: 'Offline');
    }
    
    final pending = getPendingOperations();
    if (pending.isEmpty) {
      return SyncResult(success: true, message: 'Nichts zu synchronisieren');
    }
    
    debugPrint('Syncing ${pending.length} pending operations...');
    
    int succeeded = 0;
    int failed = 0;
    final errors = <String>[];
    
    for (final op in pending) {
      try {
        // TODO: Echten API-Call implementieren
        // await _executeOperation(op);
        
        // Simuliere erfolgreiche Sync
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Bei Erfolg aus Queue entfernen
        await _syncQueueBox.delete(op.id);
        succeeded++;
        
      } catch (e) {
        failed++;
        errors.add('${op.endpoint}: $e');
        
        // Retry-Count erhöhen
        final item = _syncQueueBox.get(op.id);
        if (item != null) {
          final updated = Map<String, dynamic>.from(item);
          updated['retryCount'] = (updated['retryCount'] as int) + 1;
          
          // Nach 3 Versuchen aufgeben
          if (updated['retryCount'] >= 3) {
            await _syncQueueBox.delete(op.id);
            debugPrint('Giving up on operation after 3 retries: ${op.endpoint}');
          } else {
            await _syncQueueBox.put(op.id, updated);
          }
        }
      }
    }
    
    debugPrint('Sync complete: $succeeded succeeded, $failed failed');
    
    return SyncResult(
      success: failed == 0,
      synced: succeeded,
      failed: failed,
      errors: errors,
      message: failed == 0 
          ? '$succeeded Änderungen synchronisiert'
          : '$succeeded synchronisiert, $failed fehlgeschlagen',
    );
  }
  
  /// Anzahl ausstehender Sync-Operationen
  int get pendingCount => _syncQueueBox.length;
  
  void dispose() {
    _onlineController.close();
  }
}

// =========================================================================
// MODELS
// =========================================================================

enum SyncOperationType {
  appointment,
  anamnesis,
  consent,
  medicationLog,
  symptomCheck,
}

class SyncOperation {
  final String id;
  final SyncOperationType type;
  final String endpoint;
  final String method;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;
  
  const SyncOperation({
    required this.id,
    required this.type,
    required this.endpoint,
    required this.method,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });
}

class SyncResult {
  final bool success;
  final int synced;
  final int failed;
  final List<String> errors;
  final String message;
  
  const SyncResult({
    required this.success,
    this.synced = 0,
    this.failed = 0,
    this.errors = const [],
    required this.message,
  });
}

// =========================================================================
// CONNECTIVITY MONITOR
// =========================================================================

/// Überwacht Netzwerk-Konnektivität
class ConnectivityMonitor {
  static ConnectivityMonitor? _instance;
  static ConnectivityMonitor get instance => _instance ??= ConnectivityMonitor._();
  
  ConnectivityMonitor._();
  
  Timer? _checkTimer;
  
  /// Startet periodische Konnektivitätsprüfung
  void startMonitoring({Duration interval = const Duration(seconds: 30)}) {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(interval, (_) => _checkConnectivity());
  }
  
  void stopMonitoring() {
    _checkTimer?.cancel();
  }
  
  Future<void> _checkConnectivity() async {
    try {
      // Einfacher Ping-Test
      // TODO: Echten Connectivity-Check implementieren
      // final result = await InternetAddress.lookup('google.com');
      // final online = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      OfflineSyncManager.instance.setOnlineStatus(true);
    } catch (_) {
      OfflineSyncManager.instance.setOnlineStatus(false);
    }
  }
}
