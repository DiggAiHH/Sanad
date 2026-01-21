/// Plain Dart models for WebSocket events.
///
/// This package intentionally avoids build_runner generated code.

/// WebSocket message types.
class WSMessageType {
  // Server -> Client
  static const ticketCreated = 'ticket.created';
  static const ticketCalled = 'ticket.called';
  static const ticketCompleted = 'ticket.completed';
  static const ticketCancelled = 'ticket.cancelled';
  static const queueUpdated = 'queue.updated';
  static const checkIn = 'check_in';
  static const ledStatus = 'led.status';
  static const waitTimeUpdate = 'wait_time.update';
  static const systemNotification = 'system.notification';
  static const heartbeat = 'heartbeat';
  static const connected = 'connected';
  static const error = 'error';
  
  // Client -> Server
  static const subscribe = 'subscribe';
  static const unsubscribe = 'unsubscribe';
  static const ping = 'ping';
}

/// Base WebSocket message envelope.
class WSMessage {
  const WSMessage({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
}

/// Connection established message.
class WSConnectedData {
  const WSConnectedData({
    required this.practiceId,
    required this.serverTime,
    this.subscribedTopics,
  });

  final String practiceId;
  final List<String>? subscribedTopics;
  final String serverTime;

  factory WSConnectedData.fromJson(Map<String, dynamic> json) {
    return WSConnectedData(
      practiceId: json['practice_id']?.toString() ?? json['practiceId']?.toString() ?? '',
      subscribedTopics: (json['subscribed_topics'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      serverTime: json['server_time']?.toString() ?? json['serverTime']?.toString() ?? '',
    );
  }
}

/// Ticket created event data.
class TicketCreatedEvent {
  const TicketCreatedEvent({
    required this.ticketId,
    required this.ticketNumber,
    required this.queueId,
    required this.queueName,
    required this.estimatedWaitMinutes,
    required this.checkInMethod,
    this.patientName,
  });

  final String ticketId;
  final String ticketNumber;
  final String queueId;
  final String queueName;
  final String? patientName;
  final int estimatedWaitMinutes;
  final String checkInMethod;

  factory TicketCreatedEvent.fromJson(Map<String, dynamic> json) {
    return TicketCreatedEvent(
      ticketId: json['ticket_id']?.toString() ?? json['ticketId']?.toString() ?? '',
      ticketNumber: json['ticket_number']?.toString() ?? json['ticketNumber']?.toString() ?? '',
      queueId: json['queue_id']?.toString() ?? json['queueId']?.toString() ?? '',
      queueName: json['queue_name']?.toString() ?? json['queueName']?.toString() ?? '',
      patientName: json['patient_name']?.toString() ?? json['patientName']?.toString(),
      estimatedWaitMinutes: (json['estimated_wait_minutes'] as num?)?.toInt() ??
          (json['estimatedWaitMinutes'] as num?)?.toInt() ??
          0,
      checkInMethod: json['check_in_method']?.toString() ?? json['checkInMethod']?.toString() ?? '',
    );
  }
}

/// Ticket called event data.
class TicketCalledEvent {
  const TicketCalledEvent({
    required this.ticketId,
    required this.ticketNumber,
    required this.queueId,
    this.roomNumber,
    this.calledBy,
  });

  final String ticketId;
  final String ticketNumber;
  final String queueId;
  final String? roomNumber;
  final String? calledBy;

  factory TicketCalledEvent.fromJson(Map<String, dynamic> json) {
    return TicketCalledEvent(
      ticketId: json['ticket_id']?.toString() ?? json['ticketId']?.toString() ?? '',
      ticketNumber: json['ticket_number']?.toString() ?? json['ticketNumber']?.toString() ?? '',
      queueId: json['queue_id']?.toString() ?? json['queueId']?.toString() ?? '',
      roomNumber: json['room_number']?.toString() ?? json['roomNumber']?.toString(),
      calledBy: json['called_by']?.toString() ?? json['calledBy']?.toString(),
    );
  }
}

/// Queue update event data.
class QueueUpdateEvent {
  const QueueUpdateEvent({
    required this.queueId,
    required this.queueName,
    required this.waitingCount,
    required this.currentNumber,
    required this.averageWaitMinutes,
  });

  final String queueId;
  final String queueName;
  final int waitingCount;
  final int currentNumber;
  final int averageWaitMinutes;

  factory QueueUpdateEvent.fromJson(Map<String, dynamic> json) {
    return QueueUpdateEvent(
      queueId: json['queue_id']?.toString() ?? json['queueId']?.toString() ?? '',
      queueName: json['queue_name']?.toString() ?? json['queueName']?.toString() ?? '',
      waitingCount: (json['waiting_count'] as num?)?.toInt() ??
          (json['waitingCount'] as num?)?.toInt() ??
          0,
      currentNumber: (json['current_number'] as num?)?.toInt() ??
          (json['currentNumber'] as num?)?.toInt() ??
          0,
      averageWaitMinutes: (json['average_wait_minutes'] as num?)?.toInt() ??
          (json['averageWaitMinutes'] as num?)?.toInt() ??
          0,
    );
  }
}

/// Wait time update event data.
class WaitTimeUpdateEvent {
  const WaitTimeUpdateEvent({
    required this.zoneId,
    required this.zoneName,
    required this.currentWaitMinutes,
    required this.status,
    required this.color,
    required this.patientCount,
  });

  final String zoneId;
  final String zoneName;
  final int currentWaitMinutes;
  final String status; // 'ok', 'warning', 'critical'
  final String color; // Hex color
  final int patientCount;

  factory WaitTimeUpdateEvent.fromJson(Map<String, dynamic> json) {
    return WaitTimeUpdateEvent(
      zoneId: json['zone_id']?.toString() ?? json['zoneId']?.toString() ?? '',
      zoneName: json['zone_name']?.toString() ?? json['zoneName']?.toString() ?? '',
      currentWaitMinutes: (json['current_wait_minutes'] as num?)?.toInt() ??
          (json['currentWaitMinutes'] as num?)?.toInt() ??
          0,
      status: json['status']?.toString() ?? 'ok',
      color: json['color']?.toString() ?? '#00FF00',
      patientCount: (json['patient_count'] as num?)?.toInt() ??
          (json['patientCount'] as num?)?.toInt() ??
          0,
    );
  }
}

/// LED status event data.
class LEDStatusEvent {
  const LEDStatusEvent({
    required this.controllerId,
    required this.segmentId,
    required this.isOn,
    required this.color,
    this.pattern,
  });

  final String controllerId;
  final int segmentId;
  final bool isOn;
  final String color;
  final String? pattern;

  factory LEDStatusEvent.fromJson(Map<String, dynamic> json) {
    return LEDStatusEvent(
      controllerId: json['controller_id']?.toString() ?? json['controllerId']?.toString() ?? '',
      segmentId: (json['segment_id'] as num?)?.toInt() ??
          (json['segmentId'] as num?)?.toInt() ??
          0,
      isOn: (json['is_on'] as bool?) ?? (json['isOn'] as bool?) ?? false,
      color: json['color']?.toString() ?? '#000000',
      pattern: json['pattern']?.toString(),
    );
  }
}

/// WebSocket connection state.
sealed class WSConnectionState {
  const WSConnectionState();

  const factory WSConnectionState.disconnected() = WSDisconnected;
  const factory WSConnectionState.connecting() = WSConnecting;
  const factory WSConnectionState.connected({
    required String practiceId,
    List<String>? topics,
  }) = WSConnected;
  const factory WSConnectionState.reconnecting({required int attempt}) = WSReconnecting;
  const factory WSConnectionState.error({required String message}) = WSError;
}

final class WSDisconnected extends WSConnectionState {
  const WSDisconnected();
}

final class WSConnecting extends WSConnectionState {
  const WSConnecting();
}

final class WSConnected extends WSConnectionState {
  const WSConnected({required this.practiceId, this.topics});
  final String practiceId;
  final List<String>? topics;
}

final class WSReconnecting extends WSConnectionState {
  const WSReconnecting({required this.attempt});
  final int attempt;
}

final class WSError extends WSConnectionState {
  const WSError({required this.message});
  final String message;
}
