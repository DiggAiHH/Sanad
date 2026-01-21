import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../nfc/nfc_models.dart';
import '../nfc/nfc_service.dart';
import '../wayfinding/wayfinding_models.dart';
import '../wayfinding/wayfinding_service.dart';
import '../websocket/event_models.dart';
import '../websocket/websocket_service.dart';

// ============================================================================
// Service Providers
// ============================================================================

/// API base URL provider.
final apiBaseUrlProvider = Provider<String>((ref) {
  return const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
});

/// WebSocket base URL provider.
final wsBaseUrlProvider = Provider<String>((ref) {
  final apiUrl = ref.watch(apiBaseUrlProvider);
  return apiUrl.replaceFirst('http', 'ws');
});

/// Dio HTTP client provider.
final dioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(apiBaseUrlProvider);

  return Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
});

/// NFC service provider.
final nfcServiceProvider = Provider<NFCService>((ref) {
  final dio = ref.watch(dioProvider);
  final baseUrl = ref.watch(apiBaseUrlProvider);
  return NFCService(dio, baseUrl: baseUrl);
});

/// WebSocket service provider.
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final baseUrl = ref.watch(wsBaseUrlProvider);
  final service = WebSocketService(baseUrl: baseUrl);

  ref.onDispose(() {
    // ignore: discarded_futures
    service.dispose();
  });

  return service;
});

/// Wayfinding service provider.
final wayfindingServiceProvider = Provider<WayfindingService>((ref) {
  final dio = ref.watch(dioProvider);
  final baseUrl = ref.watch(apiBaseUrlProvider);
  return WayfindingService(dio, baseUrl: baseUrl);
});

// ============================================================================
// NFC State Providers
// ============================================================================

/// NFC state notifier.
class NFCStateNotifier extends StateNotifier<NFCState> {
  NFCStateNotifier({
    required this.nfcService,
    required this.wayfindingService,
  }) : super(const NFCState.idle());

  final NFCService nfcService;
  final WayfindingService wayfindingService;
  
  /// Start NFC scanning.
  Future<void> startScanning({
    required String deviceId,
    required String deviceSecret,
  }) async {
    if (!await nfcService.isAvailable()) {
      state = const NFCState.unavailable(reason: 'NFC nicht verfügbar');
      return;
    }
    
    state = const NFCState.scanning();
    
    await nfcService.startScanning(
      onTagDiscovered: (result) async {
        state = NFCState.processing(uid: result.uid);
        
        final response = await nfcService.performCheckIn(
          result,
          deviceId: deviceId,
          deviceSecret: deviceSecret,
        );
        
        if (response.success && (response.ticketNumber?.isNotEmpty ?? false)) {
          state = NFCState.success(response: response);
          
          // Trigger wayfinding if route is available
          if (response.wayfindingRouteId != null) {
            await _triggerWayfinding(response.wayfindingRouteId!);
          }
        } else {
          state = NFCState.error(message: response.message);
        }
        
        // Reset to scanning after delay
        await Future.delayed(const Duration(seconds: 5));
        if (state is! NFCStateIdle) {
          state = const NFCState.scanning();
        }
      },
      onError: (error) {
        state = NFCState.error(message: error);
      },
    );
  }
  
  /// Stop NFC scanning.
  Future<void> stopScanning() async {
    await nfcService.stopScanning();
    state = const NFCState.idle();
  }
  
  /// Reset state to idle.
  void reset() {
    state = const NFCState.idle();
  }

  /// Mark the NFC flow as unavailable (e.g., missing device credentials).
  void markUnavailable(String reason) {
    state = NFCState.unavailable(reason: reason);
  }
  
  Future<void> _triggerWayfinding(String routeId) async {
    try {
      await wayfindingService.triggerRoute(TriggerRouteRequest(
        routeId: routeId,
        durationSeconds: 30,
      ));
    } catch (e) {
      // Non-critical, log but don't fail
    }
  }
}

final nfcStateNotifierProvider =
    StateNotifierProvider<NFCStateNotifier, NFCState>((ref) {
  return NFCStateNotifier(
    nfcService: ref.watch(nfcServiceProvider),
    wayfindingService: ref.watch(wayfindingServiceProvider),
  );
});

// ============================================================================
// WebSocket Connection Providers
// ============================================================================

/// WebSocket connection state notifier.
class WSConnectionNotifier extends StateNotifier<WSConnectionState> {
  WSConnectionNotifier({required this.webSocketService})
      : super(const WSConnectionState.disconnected());

  final WebSocketService webSocketService;

  StreamSubscription<WSConnectionState>? _subscription;
  
  /// Connect to WebSocket.
  Future<void> connect({
    required String practiceId,
    List<String>? topics,
  }) async {
    // Listen to connection state changes
    await _subscription?.cancel();
    _subscription = webSocketService.connectionState.listen((next) {
      state = next;
    });

    await webSocketService.connect(
      practiceId: practiceId,
      topics: topics,
    );
  }
  
  /// Disconnect from WebSocket.
  Future<void> disconnect() async {
    await webSocketService.disconnect();
    state = const WSConnectionState.disconnected();
  }
  
  /// Subscribe to topics.
  void subscribe(List<String> topics) {
    webSocketService.subscribe(topics);
  }

  @override
  void dispose() {
    // ignore: discarded_futures
    _subscription?.cancel();
    super.dispose();
  }
}

final wsConnectionNotifierProvider =
    StateNotifierProvider<WSConnectionNotifier, WSConnectionState>((ref) {
  return WSConnectionNotifier(webSocketService: ref.watch(webSocketServiceProvider));
});

// ============================================================================
// Real-Time Event Providers
// ============================================================================

/// Stream provider for ticket created events.
final ticketCreatedEventsProvider = StreamProvider<TicketCreatedEvent>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.ticketCreated;
});

/// Stream provider for ticket called events.
final ticketCalledEventsProvider = StreamProvider<TicketCalledEvent>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.ticketCalled;
});

/// Stream provider for queue update events.
final queueUpdateEventsProvider = StreamProvider<QueueUpdateEvent>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.queueUpdates;
});

/// Stream provider for wait time updates.
final waitTimeEventsProvider = StreamProvider<WaitTimeUpdateEvent>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.waitTimeUpdates;
});

// ============================================================================
// Wait Time Overview Provider
// ============================================================================

/// Wait time overview provider.
final waitTimeOverviewProvider = FutureProvider<WaitTimeOverview>((ref) async {
  final wayfindingService = ref.read(wayfindingServiceProvider);
  return wayfindingService.getWaitTimeOverview();
});

// ============================================================================
// Zones and Routes Providers
// ============================================================================

/// Zones list provider.
final zonesProvider = FutureProvider<List<Zone>>((ref) async {
  final wayfindingService = ref.read(wayfindingServiceProvider);
  return wayfindingService.getZones();
});

/// Wayfinding routes provider.
final wayfindingRoutesProvider = FutureProvider<List<WayfindingRoute>>((ref) async {
  final wayfindingService = ref.read(wayfindingServiceProvider);
  return wayfindingService.getRoutes();
});
