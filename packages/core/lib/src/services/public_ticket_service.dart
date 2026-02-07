import '../models/public_ticket.dart';
import 'api_service.dart';

/// Service for public ticket status lookups (no auth required).
class PublicTicketService {
  final ApiService _api;

  PublicTicketService({required ApiService apiService}) : _api = apiService;

  /// Fetch ticket status by display number.
  Future<PublicTicket> getTicketStatus(String ticketNumber) async {
    final response = await _api.get('/tickets/$ticketNumber/status');
    return PublicTicket.fromJson(response.data as Map<String, dynamic>);
  }
}
