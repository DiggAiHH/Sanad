import 'package:freezed_annotation/freezed_annotation.dart';
import 'ticket.dart';

part 'queue.freezed.dart';
part 'queue.g.dart';

/// Queue category (different lines)
@freezed
class QueueCategory with _$QueueCategory {
  const factory QueueCategory({
    required String id,
    required String name,
    required String prefix, // A, B, C, etc.
    String? description,
    @Default(0) int currentNumber,
    @Default(true) bool isActive,
    @Default('#2196F3') String color, // Hex color
  }) = _QueueCategory;

  factory QueueCategory.fromJson(Map<String, dynamic> json) =>
      _$QueueCategoryFromJson(json);
}

/// Queue state for a practice
@freezed
class QueueState with _$QueueState {
  const factory QueueState({
    required String practiceId,
    required List<QueueCategory> categories,
    required List<Ticket> activeTickets,
    required int totalWaiting,
    required int totalInProgress,
    int? averageWaitMinutes,
    required DateTime lastUpdated,
  }) = _QueueState;

  factory QueueState.fromJson(Map<String, dynamic> json) =>
      _$QueueStateFromJson(json);
}

extension QueueStateExtension on QueueState {
  List<Ticket> get waitingTickets =>
      activeTickets.where((t) => t.status == TicketStatus.waiting).toList();

  List<Ticket> get calledTickets =>
      activeTickets.where((t) => t.status == TicketStatus.called).toList();

  List<Ticket> get inProgressTickets =>
      activeTickets.where((t) => t.status == TicketStatus.inProgress).toList();
}
