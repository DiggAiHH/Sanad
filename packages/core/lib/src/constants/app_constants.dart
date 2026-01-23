/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Sanad';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Queue
  static const List<String> defaultQueuePrefixes = ['A', 'B', 'C', 'D'];
  static const int maxTicketsPerCategory = 999;

  // Chat
  static const int maxMessageLength = 4000;
  static const int messageLoadLimit = 50;

  // Storage keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
  static const String keyPracticeId = 'practice_id';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';
  static const String keyLastTicketNumber = 'last_ticket_number';

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // File size limits
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10 MB
  static const int maxVideoSizeBytes = 100 * 1024 * 1024; // 100 MB
  static const int maxFileSizeBytes = 50 * 1024 * 1024; // 50 MB
}
