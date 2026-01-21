import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_models_freezed.freezed.dart';
part 'event_models_freezed.g.dart';

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
@freezed
class WSMessage with _$WSMessage {
  const factory WSMessage({
    required String type,
    required Map<String, dynamic> data,
    required DateTime timestamp,
  }) = _WSMessage;

  factory WSMessage.fromJson(Map<String, dynamic> json) =>
      _$WSMessageFromJson(json);
}

/// Connection established message.
@freezed
class WSConnectedData with _$WSConnectedData {
  const factory WSConnectedData({
    @JsonKey(name: 'practice_id') required String practiceId,
    @JsonKey(name: 'server_time') required String serverTime,
    @JsonKey(name: 'subscribed_topics') List<String>? subscribedTopics,
  }) = _WSConnectedData;

  factory WSConnectedData.fromJson(Map<String, dynamic> json) =>
      _$WSConnectedDataFromJson(json);
}

/// Ticket created event data.
@freezed
class TicketCreatedEvent with _$TicketCreatedEvent {
  const factory TicketCreatedEvent({
    @JsonKey(name: 'ticket_id') required String ticketId,
    @JsonKey(name: 'ticket_number') required String ticketNumber,
    @JsonKey(name: 'queue_id') required String queueId,
    @JsonKey(name: 'queue_name') required String queueName,
    @JsonKey(name: 'patient_name') String? patientName,
    @JsonKey(name: 'estimated_wait_minutes') required int estimatedWaitMinutes,
    @JsonKey(name: 'check_in_method') required String checkInMethod,
  }) = _TicketCreatedEvent;

  factory TicketCreatedEvent.fromJson(Map<String, dynamic> json) =>
      _$TicketCreatedEventFromJson(json);
}

/// Ticket called event data.
@freezed
class TicketCalledEvent with _$TicketCalledEvent {
  const factory TicketCalledEvent({
    @JsonKey(name: 'ticket_id') required String ticketId,
    @JsonKey(name: 'ticket_number') required String ticketNumber,
    @JsonKey(name: 'queue_name') required String queueName,
    @JsonKey(name: 'assigned_room') String? assignedRoom,
    @JsonKey(name: 'called_by') String? calledBy,
  }) = _TicketCalledEvent;

  factory TicketCalledEvent.fromJson(Map<String, dynamic> json) =>
      _$TicketCalledEventFromJson(json);
}

/// Ticket completed event data.
@freezed
class TicketCompletedEvent with _$TicketCompletedEvent {
  const factory TicketCompletedEvent({
    @JsonKey(name: 'ticket_id') required String ticketId,
    @JsonKey(name: 'ticket_number') required String ticketNumber,
    @JsonKey(name: 'completed_by') String? completedBy,
    @JsonKey(name: 'duration_minutes') int? durationMinutes,
  }) = _TicketCompletedEvent;

  factory TicketCompletedEvent.fromJson(Map<String, dynamic> json) =>
      _$TicketCompletedEventFromJson(json);
}

/// Queue updated event data.
@freezed
class QueueUpdatedEvent with _$QueueUpdatedEvent {
  const factory QueueUpdatedEvent({
    @JsonKey(name: 'queue_id') required String queueId,
    @JsonKey(name: 'queue_name') required String queueName,
    @JsonKey(name: 'waiting_count') required int waitingCount,
    @JsonKey(name: 'current_wait_minutes') required int currentWaitMinutes,
    @JsonKey(name: 'current_ticket') String? currentTicket,
  }) = _QueueUpdatedEvent;

  factory QueueUpdatedEvent.fromJson(Map<String, dynamic> json) =>
      _$QueueUpdatedEventFromJson(json);
}

/// Wait time update event data.
@freezed
class WaitTimeUpdateEvent with _$WaitTimeUpdateEvent {
  const factory WaitTimeUpdateEvent({
    @JsonKey(name: 'zone_id') required String zoneId,
    @JsonKey(name: 'zone_name') required String zoneName,
    @JsonKey(name: 'wait_minutes') required int waitMinutes,
    required String status, // 'ok', 'warning', 'critical'
    required String color, // Hex color for LED
    @JsonKey(name: 'patient_count') required int patientCount,
  }) = _WaitTimeUpdateEvent;

  factory WaitTimeUpdateEvent.fromJson(Map<String, dynamic> json) =>
      _$WaitTimeUpdateEventFromJson(json);
}

/// LED status event data.
@freezed
class LEDStatusEvent with _$LEDStatusEvent {
  const factory LEDStatusEvent({
    @JsonKey(name: 'device_id') required String deviceId,
    @JsonKey(name: 'device_name') required String deviceName,
    @JsonKey(name: 'is_online') required bool isOnline,
    @JsonKey(name: 'current_color') String? currentColor,
    @JsonKey(name: 'active_route_id') String? activeRouteId,
  }) = _LEDStatusEvent;

  factory LEDStatusEvent.fromJson(Map<String, dynamic> json) =>
      _$LEDStatusEventFromJson(json);
}

/// Check-in event data.
@freezed
class CheckInEventData with _$CheckInEventData {
  const factory CheckInEventData({
    @JsonKey(name: 'patient_name') String? patientName,
    @JsonKey(name: 'ticket_number') required String ticketNumber,
    @JsonKey(name: 'queue_name') required String queueName,
    @JsonKey(name: 'check_in_method') required String checkInMethod,
    @JsonKey(name: 'wayfinding_active') @Default(false) bool wayfindingActive,
  }) = _CheckInEventData;

  factory CheckInEventData.fromJson(Map<String, dynamic> json) =>
      _$CheckInEventDataFromJson(json);
}

/// System notification event data.
@freezed
class SystemNotificationEvent with _$SystemNotificationEvent {
  const factory SystemNotificationEvent({
    required String level, // 'info', 'warning', 'error'
    required String title,
    required String message,
    String? action,
  }) = _SystemNotificationEvent;

  factory SystemNotificationEvent.fromJson(Map<String, dynamic> json) =>
      _$SystemNotificationEventFromJson(json);
}
