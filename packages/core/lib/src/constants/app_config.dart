/// Application configuration constants
/// 
/// Supports environment-based API URL selection for:
/// - Local development (localhost)
/// - Production (Render.com deployment)
class AppConfig {
  AppConfig._();

  /// API Base URL - Production (Render.com)
  /// Will be replaced with actual Render URL after deployment
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sanad-api.onrender.com/api/v1',
  );

  /// Local development API URL
  static const String localApiUrl = 'http://localhost:8000/api/v1';

  /// Check if running in production
  static const bool isProduction = bool.fromEnvironment(
    'dart.vm.product',
    defaultValue: false,
  );

  /// Get the appropriate API URL based on environment
  static String get effectiveApiUrl {
    // In debug mode, check if we should use local
    if (!isProduction) {
      // Use production by default for testing
      // Switch to localApiUrl for local development
      return apiBaseUrl;
    }
    return apiBaseUrl;
  }

  /// App version
  static const String appVersion = '1.0.0';

  /// App name
  static const String appName = 'Sanad';
}
