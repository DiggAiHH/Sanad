import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../models/vaccinations.dart';

/// Service for vaccination records and recall reminders.
class VaccinationsService {
  final Dio _dio;

  /// Creates the service with a shared Dio instance.
  VaccinationsService(this._dio);

  /// Loads all vaccinations for the current patient.
  Future<List<VaccinationRecord>> getMyVaccinations({
    VaccineType? vaccineType,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.myVaccinations,
      queryParameters: {
        if (vaccineType != null) 'vaccine_type': vaccineTypeToJson(vaccineType),
      },
    );
    final items = response.data as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(VaccinationRecord.fromJson)
        .toList();
  }

  /// Loads the full vaccination pass.
  Future<VaccinationPass> getMyVaccinationPass() async {
    final response = await _dio.get(ApiEndpoints.myVaccinationPass);
    return VaccinationPass.fromJson(response.data as Map<String, dynamic>);
  }

  /// Loads vaccination recommendations.
  Future<List<VaccinationRecommendation>> getMyRecommendations() async {
    final response = await _dio.get(ApiEndpoints.myVaccinationRecommendations);
    final items = response.data as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(VaccinationRecommendation.fromJson)
        .toList();
  }

  /// Loads upcoming vaccinations in the next 3 months.
  Future<List<UpcomingVaccination>> getUpcomingVaccinations() async {
    final response = await _dio.get(ApiEndpoints.myUpcomingVaccinations);
    final items = response.data as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(UpcomingVaccination.fromJson)
        .toList();
  }

  /// Loads a single vaccination record.
  Future<VaccinationRecord> getVaccinationDetail(String vaccinationId) async {
    final response = await _dio.get(ApiEndpoints.myVaccination(vaccinationId));
    return VaccinationRecord.fromJson(response.data as Map<String, dynamic>);
  }

  /// Loads recall notifications.
  Future<List<RecallNotification>> getMyRecalls() async {
    final response = await _dio.get(ApiEndpoints.myVaccinationRecalls);
    final items = response.data as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(RecallNotification.fromJson)
        .toList();
  }

  /// Acknowledges a recall notification.
  Future<Map<String, dynamic>> acknowledgeRecall(String recallId) async {
    final response = await _dio.post(
      ApiEndpoints.acknowledgeVaccinationRecall(recallId),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Schedules an appointment from a recall notification.
  Future<Map<String, dynamic>> scheduleRecall({
    required String recallId,
    required String appointmentId,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.scheduleVaccinationRecall(recallId),
      queryParameters: {'appointment_id': appointmentId},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Requests WHO card export.
  Future<VaccinationExportStatus> exportWhoCard() async {
    final response = await _dio.get(ApiEndpoints.vaccinationExportWhoCard);
    return VaccinationExportStatus.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Requests EU DCC export.
  Future<VaccinationExportStatus> exportEuDcc({
    required VaccineType vaccineType,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.vaccinationExportEuDcc,
      queryParameters: {'vaccine_type': vaccineTypeToJson(vaccineType)},
    );
    return VaccinationExportStatus.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
