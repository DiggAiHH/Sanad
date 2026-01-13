import '../models/ticket.dart';
import '../models/queue.dart';
import 'api_service.dart';

/// Queue management service for ticket operations
class QueueService {
  final ApiService _api;

  QueueService({required ApiService apiService}) : _api = apiService;

  /// Get current queue state for practice
  Future<QueueState> getQueueState(String practiceId) async {
    final response = await _api.get('/practices/$practiceId/queue');
    return QueueState.fromJson(response.data as Map<String, dynamic>);
  }

  /// Issue a new ticket (Laufnummer)
  /// 
  /// Params:
  ///   - practiceId: Practice identifier
  ///   - patientId: Patient identifier
  ///   - categoryId: Queue category (determines prefix A, B, C...)
  ///   - visitReason: Optional reason for visit
  /// 
  /// Returns: Newly created Ticket
  Future<Ticket> issueTicket({
    required String practiceId,
    required String patientId,
    required String categoryId,
    String? visitReason,
  }) async {
    final response = await _api.post(
      '/practices/$practiceId/queue/tickets',
      data: {
        'patient_id': patientId,
        'category_id': categoryId,
        if (visitReason != null) 'visit_reason': visitReason,
      },
    );
    return Ticket.fromJson(response.data as Map<String, dynamic>);
  }

  /// Call next ticket in queue
  Future<Ticket?> callNextTicket({
    required String practiceId,
    String? categoryId,
    String? staffId,
    String? roomNumber,
  }) async {
    final response = await _api.post(
      '/practices/$practiceId/queue/call-next',
      data: {
        if (categoryId != null) 'category_id': categoryId,
        if (staffId != null) 'staff_id': staffId,
        if (roomNumber != null) 'room_number': roomNumber,
      },
    );
    if (response.data == null) return null;
    return Ticket.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update ticket status
  Future<Ticket> updateTicketStatus({
    required String practiceId,
    required String ticketId,
    required TicketStatus status,
    String? notes,
  }) async {
    final response = await _api.patch(
      '/practices/$practiceId/queue/tickets/$ticketId',
      data: {
        'status': status.name,
        if (notes != null) 'notes': notes,
      },
    );
    return Ticket.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get ticket by ID
  Future<Ticket> getTicket({
    required String practiceId,
    required String ticketId,
  }) async {
    final response = await _api.get('/practices/$practiceId/queue/tickets/$ticketId');
    return Ticket.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get patient's active ticket
  Future<Ticket?> getPatientActiveTicket({
    required String practiceId,
    required String patientId,
  }) async {
    final response = await _api.get(
      '/practices/$practiceId/queue/tickets',
      queryParameters: {
        'patient_id': patientId,
        'active': true,
      },
    );
    final tickets = (response.data as List)
        .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
        .toList();
    return tickets.isEmpty ? null : tickets.first;
  }

  /// Get estimated wait time
  Future<int> getEstimatedWaitTime({
    required String practiceId,
    required String ticketId,
  }) async {
    final response = await _api.get(
      '/practices/$practiceId/queue/tickets/$ticketId/wait-time',
    );
    return response.data['estimated_minutes'] as int;
  }

  /// Get queue categories
  Future<List<QueueCategory>> getCategories(String practiceId) async {
    final response = await _api.get('/practices/$practiceId/queue/categories');
    return (response.data as List)
        .map((e) => QueueCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
