import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket.freezed.dart';
part 'ticket.g.dart';

/// Ticket status in queue
enum TicketStatus {
  @JsonValue('waiting')
  waiting,
  @JsonValue('called')
  called,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('no_show')
  noShow,
}

/// Priority level for tickets
enum TicketPriority {
  @JsonValue('normal')
  normal,
  @JsonValue('urgent')
  urgent,
  @JsonValue('emergency')
  emergency,
}

/// Queue ticket model (Laufnummer)
/// Example: A33, B12, etc.
@freezed
class Ticket with _$Ticket {
  const factory Ticket({
    required String id,
    required String ticketNumber, // e.g., "A33"
    required String prefix, // e.g., "A"
    required int number, // e.g., 33
    required String patientId,
    required String practiceId,
    String? assignedStaffId,
    String? roomNumber,
    required TicketStatus status,
    @Default(TicketPriority.normal) TicketPriority priority,
    String? visitReason,
    required DateTime issuedAt,
    DateTime? calledAt,
    DateTime? startedAt,
    DateTime? completedAt,
    int? estimatedWaitMinutes,
    String? notes,
  }) = _Ticket;

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);
}

extension TicketExtension on Ticket {
  /// Display format: "A33"
  String get displayNumber => '$prefix$number';

  /// Calculate actual wait time in minutes
  int? get actualWaitMinutes {
    if (calledAt == null) return null;
    return calledAt!.difference(issuedAt).inMinutes;
  }

  bool get isActive =>
      status == TicketStatus.waiting ||
      status == TicketStatus.called ||
      status == TicketStatus.inProgress;
}
