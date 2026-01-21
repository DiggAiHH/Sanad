import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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

  factory PushNotificationPayload.fromRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    return PushNotificationPayload(
      type: _parseType(data['notification_type'] as String?),
      title: notification?.title ?? data['title'] as String? ?? '',
      body: notification?.body ?? data['body'] as String? ?? '',
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
      case 'system_alert':
        return PushNotificationType.systemAlert;
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

/// Service for managing Firebase Cloud Messaging (FCM).
///
/// Handles:
/// - FCM token retrieval and refresh
/// - Permission requests
/// - Foreground/background message handling
/// - Token registration with backend
class PushNotificationService {
  final Dio _dio;
  final Logger _logger = Logger();

  FirebaseMessaging? _messaging;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  OnPushNotification? _onNotification;
  OnPushNotification? _onNotificationTapped;

  PushNotificationService({required Dio dio}) : _dio = dio;

  /// Initialize FCM and request permissions.
  Future<void> initialize({
    OnPushNotification? onNotification,
    OnPushNotification? onNotificationTapped,
  }) async {
    _onNotification = onNotification;
    _onNotificationTapped = onNotificationTapped;

    try {
      // Initialize Firebase if not already done
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      _messaging = FirebaseMessaging.instance;

      // Request permission
      final settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        _logger.i('Push notifications authorized');
        await _setupMessageHandlers();
      } else {
        _logger.w('Push notifications denied');
      }
    } catch (e) {
      _logger.e('Failed to initialize push notifications: $e');
    }
  }

  /// Get current FCM token.
  Future<String?> getToken() async {
    try {
      return await _messaging?.getToken();
    } catch (e) {
      _logger.e('Failed to get FCM token: $e');
      return null;
    }
  }

  /// Register FCM token with backend.
  Future<bool> registerToken({
    required String fcmToken,
    String? deviceName,
    String? appVersion,
  }) async {
    try {
      final platform = _getPlatform();

      final response = await _dio.post(
        '/api/v1/push/register',
        data: {
          'fcm_token': fcmToken,
          'platform': platform,
          'device_name': deviceName,
          'app_version': appVersion,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Failed to register FCM token: $e');
      return false;
    }
  }

  /// Unregister FCM token from backend.
  Future<bool> unregisterToken(String fcmToken) async {
    try {
      final response = await _dio.post(
        '/api/v1/push/unregister',
        data: {'fcm_token': fcmToken},
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Failed to unregister FCM token: $e');
      return false;
    }
  }

  /// Initialize and register token in one call.
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

    final token = await getToken();
    if (token == null) {
      return false;
    }

    return registerToken(
      fcmToken: token,
      deviceName: deviceName,
      appVersion: appVersion,
    );
  }

  /// Subscribe to FCM topic.
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging?.subscribeToTopic(topic);
      _logger.i('Subscribed to topic: $topic');
    } catch (e) {
      _logger.e('Failed to subscribe to topic: $e');
    }
  }

  /// Unsubscribe from FCM topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging?.unsubscribeFromTopic(topic);
      _logger.i('Unsubscribed from topic: $topic');
    } catch (e) {
      _logger.e('Failed to unsubscribe from topic: $e');
    }
  }

  /// Dispose of resources.
  void dispose() {
    _foregroundSubscription?.cancel();
  }

  // ===========================================================================
  // Private Methods
  // ===========================================================================

  Future<void> _setupMessageHandlers() async {
    // Foreground messages
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      _logger.i('Foreground message received');
      final payload = PushNotificationPayload.fromRemoteMessage(message);
      _onNotification?.call(payload);
    });

    // Background message tap
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _logger.i('Notification tapped (background)');
      final payload = PushNotificationPayload.fromRemoteMessage(message);
      _onNotificationTapped?.call(payload);
    });

    // Check if app was opened from terminated state via notification
    final initialMessage = await _messaging!.getInitialMessage();
    if (initialMessage != null) {
      _logger.i('Notification opened app from terminated state');
      final payload = PushNotificationPayload.fromRemoteMessage(initialMessage);
      _onNotificationTapped?.call(payload);
    }

    // Token refresh listener
    _messaging!.onTokenRefresh.listen((newToken) async {
      _logger.i('FCM token refreshed');
      await registerToken(fcmToken: newToken);
    });
  }

  String _getPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'web';
  }
}
