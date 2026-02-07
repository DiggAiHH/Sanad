import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Push notification types matching backend schema.
enum PushNotificationType {
  ticketCalled,
  ticketCreated,
  queueUpdate,
  checkInSuccess,
  appointmentReminder,
  systemAlert,
}

/// Parsed push notification payload.
class PushNotificationPayload {
  final PushNotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;

  const PushNotificationPayload({
    required this.type,
    required this.title,
    required this.body,
    this.data = const {},
  });

  factory PushNotificationPayload.fromMap(Map<String, dynamic> data) {
    return PushNotificationPayload(
      type: _parseType(data['notification_type'] as String?),
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      data: data,
    );
  }

  static PushNotificationType _parseType(String? type) {
    switch (type) {
      case 'ticket_called':
        return PushNotificationType.ticketCalled;
      case 'ticket_created':
        return PushNotificationType.ticketCreated;
      case 'queue_update':
        return PushNotificationType.queueUpdate;
      case 'check_in_success':
        return PushNotificationType.checkInSuccess;
      case 'appointment_reminder':
        return PushNotificationType.appointmentReminder;
      default:
        return PushNotificationType.systemAlert;
    }
  }

  /// Get ticket number from data payload.
  String? get ticketNumber => data['ticket_number'] as String?;

  /// Get queue name from data payload.
  String? get queueName => data['queue_name'] as String?;

  /// Get room from data payload.
  String? get room => data['room'] as String?;
}

/// Callback for handling push notifications.
typedef OnPushNotification = void Function(PushNotificationPayload payload);

/// No-op push notification service (Firebase disabled for web testing).
class PushNotificationService {
  final Logger _logger = Logger();

  OnPushNotification? _onNotification;
  OnPushNotification? _onNotificationTapped;

  PushNotificationService({required Dio dio});

  /// Initialize push notifications (no-op).
  Future<void> initialize({
    OnPushNotification? onNotification,
    OnPushNotification? onNotificationTapped,
  }) async {
    _onNotification = onNotification;
    _onNotificationTapped = onNotificationTapped;
    _logger.i('Push notifications are disabled in this build.');
  }

  /// Get current token (disabled).
  Future<String?> getToken() async {
    _logger.i('Push notifications are disabled in this build.');
    return null;
  }

  /// Register token with backend (disabled).
  Future<bool> registerToken({
    required String fcmToken,
    String? deviceName,
    String? appVersion,
  }) async {
    _logger.i('Push notifications are disabled in this build.');
    return false;
  }

  /// Unregister token from backend (disabled).
  Future<bool> unregisterToken(String fcmToken) async {
    _logger.i('Push notifications are disabled in this build.');
    return false;
  }

  /// Initialize and register token (disabled).
  Future<bool> initializeAndRegister({
    String? deviceName,
    String? appVersion,
    OnPushNotification? onNotification,
    OnPushNotification? onNotificationTapped,
  }) async {
    await initialize(
      onNotification: onNotification,
      onNotificationTapped: onNotificationTapped,
    );
    return false;
  }

  /// Subscribe to topic (disabled).
  Future<void> subscribeToTopic(String topic) async {
    _logger.i('Push notifications are disabled in this build.');
  }

  /// Unsubscribe from topic (disabled).
  Future<void> unsubscribeFromTopic(String topic) async {
    _logger.i('Push notifications are disabled in this build.');
  }

  void dispose() {}
}
