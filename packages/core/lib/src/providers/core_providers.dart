import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/queue_service.dart';
import '../services/chat_service.dart';
import '../services/push_service.dart';
import '../services/public_ticket_service.dart';
import '../services/public_practice_service.dart';
import '../services/public_queue_summary_service.dart';
import '../services/consultation_service.dart';
import '../services/document_request_service.dart';
import '../services/encryption_service.dart';
import '../constants/app_constants.dart';

/// Storage service provider - singleton
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Dio instance provider
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: AppConstants.connectionTimeout,
    receiveTimeout: AppConstants.receiveTimeout,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
});

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthService(dio: dio);
});

/// API service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ApiService(
    baseUrl: AppConstants.apiBaseUrl,
    authService: authService,
  );
});

/// Queue service provider
final queueServiceProvider = Provider<QueueService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return QueueService(apiService: apiService);
});

/// Chat service provider
final chatServiceProvider = Provider<ChatService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ChatService(apiService: apiService);
});

/// Push notification service provider
final pushServiceProvider = Provider<PushNotificationService>((ref) {
  final dio = ref.watch(dioProvider);
  return PushNotificationService(dio: dio);
});

/// Public ticket service provider
final publicTicketServiceProvider = Provider<PublicTicketService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PublicTicketService(apiService: apiService);
});

/// Public practice service provider
final publicPracticeServiceProvider = Provider<PublicPracticeService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PublicPracticeService(apiService: apiService);
});

/// Public queue summary service provider
final publicQueueSummaryServiceProvider =
    Provider<PublicQueueSummaryService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PublicQueueSummaryService(apiService: apiService);
});

/// Consultation service provider - uses shared Dio instance.
final consultationServiceProvider = Provider<ConsultationService>((ref) {
  final dio = ref.watch(dioProvider);
  return ConsultationService(dio);
});

/// Document request service provider - uses shared Dio instance.
final documentRequestServiceProvider = Provider<DocumentRequestService>((ref) {
  final dio = ref.watch(dioProvider);
  return DocumentRequestService(dio);
});

/// Encryption service provider - singleton for E2E encryption.
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

/// Provider overrides for dependency injection
List<Override> createProviderOverrides({
  String? apiBaseUrl,
}) {
  return [
    if (apiBaseUrl != null)
      dioProvider.overrideWith((ref) {
        return Dio(BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: AppConstants.connectionTimeout,
          receiveTimeout: AppConstants.receiveTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));
      }),
  ];
}
