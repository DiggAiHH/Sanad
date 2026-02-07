import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/auth_state.dart';

/// Authentication service for all Sanad apps
/// Handles login, logout, token refresh, and session management
class AuthService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_data';

  AuthService({
    required Dio dio,
    FlutterSecureStorage? storage,
  })  : _dio = dio,
        _storage = storage ?? const FlutterSecureStorage();

  /// Login with email and password
  /// 
  /// Params:
  ///   - email: User's email address
  ///   - password: User's password
  /// 
  /// Returns: AuthState with user data and tokens
  /// 
  /// Raises: 
  ///   - DioException on network errors
  ///   - FormatException on invalid response
  /// 
  /// Security: Credentials transmitted over HTTPS only
  Future<AuthState> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      final accessToken = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String;

      await _saveTokens(accessToken, refreshToken);

      return AuthState.authenticated(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      return AuthState.error(message);
    }
  }

  /// Login with QR code token
  /// Used for tablet check-in at reception
  Future<AuthState> loginWithQrCode(String qrToken) async {
    try {
      final response = await _dio.post(
        '/auth/qr-login',
        data: {'qr_token': qrToken},
      );

      final data = response.data as Map<String, dynamic>;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      final accessToken = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String;

      await _saveTokens(accessToken, refreshToken);

      return AuthState.authenticated(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on DioException catch (e) {
      return AuthState.error(_extractErrorMessage(e));
    }
  }

  /// Login with NFC tag
  Future<AuthState> loginWithNfc(String nfcId) async {
    try {
      final response = await _dio.post(
        '/auth/nfc-login',
        data: {'nfc_id': nfcId},
      );

      final data = response.data as Map<String, dynamic>;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      final accessToken = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String;

      await _saveTokens(accessToken, refreshToken);

      return AuthState.authenticated(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on DioException catch (e) {
      return AuthState.error(_extractErrorMessage(e));
    }
  }

  /// Refresh access token
  Future<String?> refreshAccessToken() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null) return null;

    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data['access_token'] as String;
      final newRefreshToken = response.data['refresh_token'] as String?;

      await _storage.write(key: _accessTokenKey, value: newAccessToken);
      if (newRefreshToken != null) {
        await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
      }

      return newAccessToken;
    } on DioException {
      await logout();
      return null;
    }
  }

  /// Logout and clear all stored tokens
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // Ignore logout errors, clear local state anyway
    }
    await _storage.deleteAll();
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null;
  }

  /// Get current user profile
  /// 
  /// Returns: User object if authenticated, null otherwise
  /// 
  /// Raises: DioException on network errors
  Future<User?> getUserProfile() async {
    try {
      final response = await _dio.get('/auth/me');
      final data = response.data as Map<String, dynamic>;
      return User.fromJson(data);
    } on DioException {
      return null;
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      return e.response?.data['message'] as String? ?? 'Authentication failed';
    }
    return e.message ?? 'Network error';
  }
}
