import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../models/symptom_checker.dart';

/// Service for symptom checker and triage.
class SymptomCheckerService {
  final Dio _dio;

  /// Creates the service with a shared Dio instance.
  SymptomCheckerService(this._dio);

  /// Loads the symptom catalog and categories.
  Future<SymptomCatalog> getSymptomCatalog() async {
    final response = await _dio.get(ApiEndpoints.symptomCatalog);
    return SymptomCatalog.fromJson(response.data as Map<String, dynamic>);
  }

  /// Loads red flag questions.
  Future<List<RedFlag>> getRedFlags() async {
    final response = await _dio.get(ApiEndpoints.symptomRedFlags);
    final payload = response.data as Map<String, dynamic>;
    final items = payload['red_flags'] as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(RedFlag.fromJson)
        .toList();
  }

  /// Runs a symptom check.
  Future<SymptomCheckResponse> checkSymptoms(
    SymptomCheckRequest request,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.symptomCheck,
      data: request.toJson(),
    );
    return SymptomCheckResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Saves a symptom check session for later reference.
  Future<SymptomSaveResponse> saveSession(String sessionId) async {
    final response = await _dio.post(
      ApiEndpoints.symptomSaveSession,
      queryParameters: {'session_id': sessionId},
    );
    return SymptomSaveResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
