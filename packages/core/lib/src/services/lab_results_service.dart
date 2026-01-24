import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../models/lab_results.dart';

/// Service for lab results access.
class LabResultsService {
  final Dio _dio;

  /// Creates the service with a shared Dio instance.
  LabResultsService(this._dio);

  /// Loads summaries of released lab results for current patient.
  Future<List<LabResultSummary>> getMyLabResults() async {
    final response = await _dio.get(ApiEndpoints.myLabResults);
    final items = response.data as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(LabResultSummary.fromJson)
        .toList();
  }

  /// Loads full lab result details for current patient.
  Future<LabResult> getMyLabResult(String resultId) async {
    final response = await _dio.get(ApiEndpoints.myLabResult(resultId));
    return LabResult.fromJson(response.data as Map<String, dynamic>);
  }

  /// Loads pending results count.
  Future<PendingCount> getPendingCount() async {
    final response = await _dio.get(ApiEndpoints.myLabResultsPendingCount);
    return PendingCount.fromJson(response.data as Map<String, dynamic>);
  }

  /// Loads reference values for lab categories.
  Future<ReferenceValues> getReferenceValues() async {
    final response = await _dio.get(ApiEndpoints.labResultsReferenceValues);
    return ReferenceValues.fromJson(response.data as Map<String, dynamic>);
  }

  /// Releases a lab result (staff use).
  Future<Map<String, dynamic>> releaseResult(
    ReleaseResultRequest request,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.labResultsRelease,
      data: request.toJson(),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Marks a result as discussed (staff use).
  Future<Map<String, dynamic>> markResultDiscussed(String resultId) async {
    final response = await _dio.put(
      ApiEndpoints.labResultsMarkDiscussed(resultId),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
