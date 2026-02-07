import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

/// Task priority
enum TaskPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

/// Task status
enum TaskStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

/// Task model for staff assignments
@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    String? description,
    required String createdById,
    required String assignedToId,
    String? patientId,
    String? ticketId,
    required TaskPriority priority,
    required TaskStatus status,
    DateTime? dueAt,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    @Default([]) List<String> tags,
    String? notes,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

extension TaskExtension on Task {
  bool get isOverdue {
    if (dueAt == null) return false;
    if (status == TaskStatus.completed || status == TaskStatus.cancelled) {
      return false;
    }
    return DateTime.now().isAfter(dueAt!);
  }

  bool get isActive =>
      status == TaskStatus.pending || status == TaskStatus.inProgress;
}
