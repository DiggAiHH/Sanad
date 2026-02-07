import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../models/anamnesis.dart';

/// Service for anamnesis templates and submissions.
class AnamnesisService {
  final Dio _dio;

  /// Creates the service with a shared Dio instance.
  AnamnesisService(this._dio);

  /// Loads available anamnesis templates.
  Future<List<AnamnesisTemplate>> getTemplates({
    String? appointmentType,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.anamnesisTemplates,
      queryParameters: {
        if (appointmentType != null) 'appointment_type': appointmentType,
      },
    );

    final items = response.data as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(AnamnesisTemplate.fromJson)
        .toList();
  }

  /// Loads a specific template.
  Future<AnamnesisTemplate> getTemplate(String templateId) async {
    final response = await _dio.get(ApiEndpoints.anamnesisTemplate(templateId));
    return AnamnesisTemplate.fromJson(response.data as Map<String, dynamic>);
  }

  /// Submits an anamnesis form.
  Future<AnamnesisSubmission> submitAnamnesis(
    SubmitAnamnesisRequest request,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.anamnesisSubmit,
      data: request.toJson(),
    );
    return AnamnesisSubmission.fromJson(response.data as Map<String, dynamic>);
  }

  /// Loads all submissions for the current patient.
  Future<List<AnamnesisSubmission>> getMySubmissions() async {
    final response = await _dio.get(ApiEndpoints.anamnesisMySubmissions);
    final items = response.data as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(AnamnesisSubmission.fromJson)
        .toList();
  }

  /// Loads a single submission.
  Future<AnamnesisSubmission> getSubmission(String submissionId) async {
    final response = await _dio.get(
      ApiEndpoints.anamnesisSubmission(submissionId),
    );
    return AnamnesisSubmission.fromJson(response.data as Map<String, dynamic>);
  }

  /// Loads the anamnesis submission for an appointment if present.
  Future<AnamnesisSubmission?> getForAppointment(String appointmentId) async {
    final response = await _dio.get(
      ApiEndpoints.anamnesisForAppointment(appointmentId),
    );

    if (response.data == null) {
      return null;
    }
    return AnamnesisSubmission.fromJson(response.data as Map<String, dynamic>);
  }
}
