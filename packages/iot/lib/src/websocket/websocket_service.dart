import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import 'event_models.dart';

/// WebSocket service for real-time events.
/// 
/// Connects to backend WebSocket and provides streams for various event types.
/// Supports automatic reconnection with exponential backoff.
/// 
/// Usage:
/// ```dart
/// final wsService = WebSocketService(baseUrl: 'ws://localhost:8000');
/// await wsService.connect(practiceId: 'practice-123');
/// 
/// wsService.ticketEvents.listen((event) {
///   print('Ticket: ${event.ticketNumber}');
/// });
/// ```
class WebSocketService {
  /// Creates WebSocket service.
  WebSocketService({
    required this.baseUrl,
    this.reconnectDelay = const Duration(seconds: 5),
    this.maxReconnectAttempts = 10,
  });
  
  final String baseUrl;
  final Duration reconnectDelay;
  final int maxReconnectAttempts;
  
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  
  int _reconnectAttempts = 0;
  bool _intentionalDisconnect = false;
  String? _currentPracticeId;
  List<String>? _currentTopics;
  
  // State controller
  final _stateController = StreamController<WSConnectionState>.broadcast();
  
  // Event controllers
  final _ticketCreatedController = StreamController<TicketCreatedEvent>.broadcast();
  final _ticketCalledController = StreamController<TicketCalledEvent>.broadcast();
  final _queueUpdateController = StreamController<QueueUpdateEvent>.broadcast();
  final _waitTimeController = StreamController<WaitTimeUpdateEvent>.broadcast();
  final _ledStatusController = StreamController<LEDStatusEvent>.broadcast();
  final _rawMessageController = StreamController<WSMessage>.broadcast();
  
  /// Connection state stream.
  Stream<WSConnectionState> get connectionState => _stateController.stream;
  
  /// Ticket created events.
  Stream<TicketCreatedEvent> get ticketCreated => _ticketCreatedController.stream;
  
  /// Ticket called events.
  Stream<TicketCalledEvent> get ticketCalled => _ticketCalledController.stream;
  
  /// Queue update events.
  Stream<QueueUpdateEvent> get queueUpdates => _queueUpdateController.stream;
  
  /// Wait time update events.
  Stream<WaitTimeUpdateEvent> get waitTimeUpdates => _waitTimeController.stream;
  
  /// LED status events.
  Stream<LEDStatusEvent> get ledStatus => _ledStatusController.stream;
  
  /// All raw messages.
  Stream<WSMessage> get rawMessages => _rawMessageController.stream;
  
  /// Current connection state.
  bool get isConnected => _channel != null;
  
  /// Connect to WebSocket server.
  Future<void> connect({
    required String practiceId,
    List<String>? topics,
  }) async {
    _intentionalDisconnect = false;
    _currentPracticeId = practiceId;
    _currentTopics = topics;
    
    _stateController.add(const WSConnectionState.connecting());
    
    try {
      final topicsParam = topics != null ? '?topics=${topics.join(",")}' : '';
      final uri = Uri.parse('$baseUrl/api/v1/ws/events/$practiceId$topicsParam');
      
      _channel = WebSocketChannel.connect(uri);
      
      // Wait for connection to be established
      await _channel!.ready;
      
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
      );
      
      _startHeartbeat();
      _reconnectAttempts = 0;
      
      _stateController.add(WSConnectionState.connected(
        practiceId: practiceId,
        topics: topics,
      ));
      
      debugPrint('WebSocket connected to $uri');
    } catch (e) {
      debugPrint('WebSocket connection failed: $e');
      _stateController.add(WSConnectionState.error(message: e.toString()));
      _scheduleReconnect();
    }
  }
  
  /// Disconnect from WebSocket server.
  Future<void> disconnect() async {
    _intentionalDisconnect = true;
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    
    await _subscription?.cancel();
    await _channel?.sink.close(ws_status.normalClosure);
    
    _channel = null;
    _stateController.add(const WSConnectionState.disconnected());
    
    debugPrint('WebSocket disconnected');
  }
  
  /// Subscribe to additional topics.
  void subscribe(List<String> topics) {
    if (_channel == null) return;
    
    _send({
      'type': WSMessageType.subscribe,
      'data': {'topics': topics},
    });
  }
  
  /// Unsubscribe from topics.
  void unsubscribe(List<String> topics) {
    if (_channel == null) return;
    
    _send({
      'type': WSMessageType.unsubscribe,
      'data': {'topics': topics},
    });
  }
  
  /// Send ping to check connection.
  void ping() {
    _send({'type': WSMessageType.ping, 'data': {}});
  }
  
  /// Dispose and clean up resources.
  Future<void> dispose() async {
    await disconnect();
    await _stateController.close();
    await _ticketCreatedController.close();
    await _ticketCalledController.close();
    await _queueUpdateController.close();
    await _waitTimeController.close();
    await _ledStatusController.close();
    await _rawMessageController.close();
  }
  
  // ========== Private Methods ==========
  
  void _handleMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      
      // Parse timestamp
      DateTime timestamp;
      if (json['timestamp'] != null) {
        timestamp = DateTime.parse(json['timestamp'] as String);
      } else {
        timestamp = DateTime.now();
      }
      
      final message = WSMessage(
        type: json['type'] as String,
        data: json['data'] as Map<String, dynamic>,
        timestamp: timestamp,
      );
      
      _rawMessageController.add(message);
      _routeMessage(message);
    } catch (e) {
      debugPrint('Failed to parse WebSocket message: $e');
    }
  }
  
  void _routeMessage(WSMessage message) {
    switch (message.type) {
      case WSMessageType.ticketCreated:
        _ticketCreatedController.add(
          TicketCreatedEvent.fromJson(message.data),
        );
        break;
        
      case WSMessageType.ticketCalled:
        _ticketCalledController.add(
          TicketCalledEvent.fromJson(message.data),
        );
        break;
        
      case WSMessageType.queueUpdated:
        _queueUpdateController.add(
          QueueUpdateEvent.fromJson(message.data),
        );
        break;
        
      case WSMessageType.waitTimeUpdate:
        _waitTimeController.add(
          WaitTimeUpdateEvent.fromJson(message.data),
        );
        break;
        
      case WSMessageType.ledStatus:
        _ledStatusController.add(
          LEDStatusEvent.fromJson(message.data),
        );
        break;
        
      case WSMessageType.connected:
        debugPrint('WebSocket: Connected confirmation received');
        break;
        
      case WSMessageType.heartbeat:
        // Heartbeat received, connection is alive
        break;
        
      case WSMessageType.error:
        debugPrint('WebSocket error: ${message.data['message']}');
        break;
    }
  }
  
  void _handleError(dynamic error) {
    debugPrint('WebSocket error: $error');
    _stateController.add(WSConnectionState.error(message: error.toString()));
  }
  
  void _handleDone() {
    debugPrint('WebSocket connection closed');
    _channel = null;
    _stopHeartbeat();
    
    if (!_intentionalDisconnect) {
      _scheduleReconnect();
    } else {
      _stateController.add(const WSConnectionState.disconnected());
    }
  }
  
  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      debugPrint('Max reconnect attempts reached');
      _stateController.add(const WSConnectionState.error(
        message: 'Verbindung konnte nicht wiederhergestellt werden',
      ));
      return;
    }
    
    _reconnectAttempts++;
    
    // Exponential backoff
    final delay = Duration(
      milliseconds: reconnectDelay.inMilliseconds * _reconnectAttempts,
    );
    
    _stateController.add(WSConnectionState.reconnecting(
      attempt: _reconnectAttempts,
    ));
    
    debugPrint('Scheduling reconnect in ${delay.inSeconds}s (attempt $_reconnectAttempts)');
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (_currentPracticeId != null) {
        connect(
          practiceId: _currentPracticeId!,
          topics: _currentTopics,
        );
      }
    });
  }
  
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      ping();
    });
  }
  
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }
  
  void _send(Map<String, dynamic> data) {
    if (_channel == null) return;
    
    try {
      _channel!.sink.add(jsonEncode(data));
    } catch (e) {
      debugPrint('Failed to send WebSocket message: $e');
    }
  }
}
