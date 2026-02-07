import 'dart:math';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'auth_service.dart';

/// Base API service with interceptors for auth and error handling
class ApiService {
  late final Dio dio;
  final AuthService _authService;
  final Logger _logger = Logger();
  final String baseUrl;
  final Random _jitter = Random();

  static const int _maxRetries = 2;
  static const Duration _baseRetryDelay = Duration(milliseconds: 300);
  static const Set<String> _idempotentMethods = {
    'GET',
    'HEAD',
    'OPTIONS',
  };

  ApiService({
    required this.baseUrl,
    required AuthService authService,
  }) : _authService = authService {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          _logger.d('API Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('API Response: ${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) async {
          _logger.e('API Error: ${error.response?.statusCode} ${error.requestOptions.path}');
          
          // Handle 401 - Attempt token refresh
          if (error.response?.statusCode == 401) {
            final newToken = await _authService.refreshAccessToken();
            if (newToken != null) {
              // Retry the request with new token
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              try {
                final response = await dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              } catch (e) {
                handler.reject(error);
                return;
              }
            }
          }

          if (await _shouldRetry(error)) {
            final response = await _retryRequest(error, handler);
            if (response) {
              return;
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  // =========================================================================
  // Retry helpers
  // =========================================================================

  Future<bool> _shouldRetry(DioException error) async {
    final request = error.requestOptions;
    final retryCount = (request.extra['retryCount'] as int?) ?? 0;
    if (retryCount >= _maxRetries) {
      return false;
    }

    final isIdempotent = _idempotentMethods.contains(request.method.toUpperCase());
    final allowRetry = (request.extra['retry'] as bool?) ?? isIdempotent;
    if (!allowRetry) {
      return false;
    }

    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      return statusCode == 408 ||
          statusCode == 429 ||
          statusCode == 500 ||
          statusCode == 502 ||
          statusCode == 503 ||
          statusCode == 504;
    }

    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown;
  }

  Future<bool> _retryRequest(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final request = error.requestOptions;
    final retryCount = (request.extra['retryCount'] as int?) ?? 0;
    final nextRetry = retryCount + 1;
    request.extra['retryCount'] = nextRetry;

    final delay = _backoffDelay(nextRetry);
    _logger.w(
      'Retrying request (${request.method} ${request.path}) in ${delay.inMilliseconds}ms',
    );
    await Future.delayed(delay);

    try {
      final response = await dio.fetch(request);
      handler.resolve(response);
      return true;
    } on DioException catch (dioError) {
      handler.reject(dioError);
      return true;
    } catch (_) {
      handler.reject(error);
      return true;
    }
  }

  Duration _backoffDelay(int attempt) {
    final exponential = _baseRetryDelay * (1 << (attempt - 1));
    final jitterMs = _jitter.nextInt(120);
    return exponential + Duration(milliseconds: jitterMs);
  }
}
