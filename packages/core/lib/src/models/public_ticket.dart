import 'ticket.dart';

/// Public ticket data for patient-facing status checks.
class PublicTicket {
  /// Queue identifier the ticket belongs to.
  final String queueId;

  /// Display number shown to patients (e.g. "A-042").
  final String ticketNumber;

  /// Current status in the queue lifecycle.
  final TicketStatus status;

  /// Estimated wait time in minutes.
  final int estimatedWaitMinutes;

  /// Time when the ticket was called, if applicable.
  final DateTime? calledAt;

  /// Time when the ticket was completed, if applicable.
  final DateTime? completedAt;

  /// Timestamp when the ticket was created.
  final DateTime createdAt;

  const PublicTicket({
    required this.queueId,
    required this.ticketNumber,
    required this.status,
    required this.estimatedWaitMinutes,
    required this.calledAt,
    required this.completedAt,
    required this.createdAt,
  });

  /// Create a PublicTicket from API response JSON.
  factory PublicTicket.fromJson(Map<String, dynamic> json) {
    return PublicTicket(
      queueId: json['queue_id'] as String,
      ticketNumber: json['ticket_number'] as String,
      status: _parseStatus(json['status'] as String),
      estimatedWaitMinutes: json['estimated_wait_minutes'] as int,
      calledAt: _parseDate(json['called_at']),
      completedAt: _parseDate(json['completed_at']),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    return null;
  }

  static TicketStatus _parseStatus(String value) {
    switch (value) {
      case 'waiting':
        return TicketStatus.waiting;
      case 'called':
        return TicketStatus.called;
      case 'in_progress':
        return TicketStatus.inProgress;
      case 'completed':
        return TicketStatus.completed;
      case 'cancelled':
        return TicketStatus.cancelled;
      case 'no_show':
        return TicketStatus.noShow;
    }
    return TicketStatus.waiting;
  }
}
