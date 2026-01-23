import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../models/medication.dart';

/// Service for patient medication plan data.
class MedicationService {
  final Dio _dio;

  MedicationService(this._dio);

  /// Loads the patient's medications.
  Future<List<Medication>> getMyMedications() async {
    final response = await _dio.get(ApiEndpoints.myMedications);
    final items = response.data as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(Medication.fromJson)
        .toList();
  }

  /// Loads the full medication plan.
  Future<MedicationPlan> getMedicationPlan() async {
    final response = await _dio.get(ApiEndpoints.myMedicationPlan);
    return MedicationPlan.fromJson(response.data as Map<String, dynamic>);
  }
}
