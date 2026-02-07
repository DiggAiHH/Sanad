import '../models/public_queue_summary.dart';
import 'api_service.dart';

/// Service for public queue summary (no auth required).
class PublicQueueSummaryService {
  final ApiService _api;

  PublicQueueSummaryService({required ApiService apiService}) : _api = apiService;

  /// Fetch queue summary for the patient home screen.
  Future<PublicQueueSummary> getSummary({String? practiceId}) async {
    final response = await _api.get(
      '/queue/public/summary',
      queryParameters:
          practiceId == null ? null : {'practice_id': practiceId},
    );
    return PublicQueueSummary.fromJson(response.data as Map<String, dynamic>);
  }
}
