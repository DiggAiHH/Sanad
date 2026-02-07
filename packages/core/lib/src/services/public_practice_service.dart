import '../models/public_practice.dart';
import 'api_service.dart';

/// Service for public practice info (no auth required).
class PublicPracticeService {
  final ApiService _api;

  PublicPracticeService({required ApiService apiService}) : _api = apiService;

  /// Fetch the default practice for patient apps.
  Future<PublicPractice> getDefaultPractice({String? practiceId}) async {
    final response = await _api.get(
      '/practice/public/default',
      queryParameters:
          practiceId == null ? null : {'practice_id': practiceId},
    );
    return PublicPractice.fromJson(response.data as Map<String, dynamic>);
  }
}
