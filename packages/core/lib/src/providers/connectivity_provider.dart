import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../services/offline_service.dart';

/// Connectivity state enum.
enum ConnectivityStatus {
  /// Device is online
  online,

  /// Device is offline
  offline,

  /// Checking connectivity
  checking,
}

/// Connectivity notifier with offline queue integration.
class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  final Connectivity _connectivity;
  final OfflineService _offlineService;
  final Logger _logger = Logger();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityNotifier({
    required OfflineService offlineService,
  })  : _connectivity = Connectivity(),
        _offlineService = offlineService,
        super(ConnectivityStatus.checking) {
    _initialize();
  }

  /// Whether the device is currently online.
  bool get isOnline => state == ConnectivityStatus.online;

  /// Whether the device is currently offline.
  bool get isOffline => state == ConnectivityStatus.offline;

  Future<void> _initialize() async {
    // Check initial connectivity
    await _checkConnectivity();

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) => _handleConnectivityChange(results),
    );
  }

  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleConnectivityChange(results);
    } catch (e, stack) {
      _logger.e('Failed to check connectivity', error: e, stackTrace: stack);
      state = ConnectivityStatus.offline;
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final wasOffline = state == ConnectivityStatus.offline;

    // Check if any connection is available
    final hasConnection = results.any((r) => r != ConnectivityResult.none);

    if (hasConnection) {
      state = ConnectivityStatus.online;
      _logger.i('Device is online');

      // If we were offline and now online, process pending operations
      if (wasOffline && _offlineService.hasPending) {
        _logger.i('Connectivity restored, processing offline queue...');
        // Note: Actual processing should be triggered by the app
        // This is just a notification
      }
    } else {
      state = ConnectivityStatus.offline;
      _logger.w('Device is offline');
    }
  }

  /// Manually refresh connectivity status.
  Future<void> refresh() async {
    state = ConnectivityStatus.checking;
    await _checkConnectivity();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Provider for offline service (singleton).
final offlineServiceProvider = Provider<OfflineService>((ref) {
  final service = OfflineService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for connectivity status.
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  final offlineService = ref.watch(offlineServiceProvider);
  return ConnectivityNotifier(offlineService: offlineService);
});

/// Provider for pending offline operations count.
final pendingOperationsProvider = StreamProvider<int>((ref) {
  final offlineService = ref.watch(offlineServiceProvider);
  return offlineService.queueStream.map((queue) => queue.length);
});

/// Provider that returns true if device is online.
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider) == ConnectivityStatus.online;
});
