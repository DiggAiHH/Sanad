/// Summary information for a single queue.
class PublicQueueSummaryItem {
  /// Queue identifier.
  final String queueId;

  /// Queue name.
  final String name;

  /// Queue code shown to patients.
  final String code;

  /// Queue color (hex string).
  final String color;

  /// Average wait time for this queue in minutes.
  final int averageWaitMinutes;

  /// Current waiting ticket count.
  final int waitingCount;

  const PublicQueueSummaryItem({
    required this.queueId,
    required this.name,
    required this.code,
    required this.color,
    required this.averageWaitMinutes,
    required this.waitingCount,
  });

  /// Create from API JSON.
  factory PublicQueueSummaryItem.fromJson(Map<String, dynamic> json) {
    return PublicQueueSummaryItem(
      queueId: json['queue_id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      color: json['color'] as String,
      averageWaitMinutes: json['average_wait_minutes'] as int,
      waitingCount: json['waiting_count'] as int,
    );
  }
}

/// Summary payload for patient home screen.
class PublicQueueSummary {
  /// Practice identifier.
  final String practiceId;

  /// Practice name.
  final String practiceName;

  /// Opening hours string (raw backend format).
  final String? openingHours;

  /// Average wait time for the practice in minutes.
  final int averageWaitTimeMinutes;

  /// Current called ticket number, if any.
  final String? nowServingTicket;

  /// Queue summaries.
  final List<PublicQueueSummaryItem> queues;

  /// Timestamp when the summary was generated.
  final DateTime generatedAt;

  const PublicQueueSummary({
    required this.practiceId,
    required this.practiceName,
    required this.openingHours,
    required this.averageWaitTimeMinutes,
    required this.nowServingTicket,
    required this.queues,
    required this.generatedAt,
  });

  /// Create from API JSON.
  factory PublicQueueSummary.fromJson(Map<String, dynamic> json) {
    final queuesJson = json['queues'] as List<dynamic>? ?? [];
    return PublicQueueSummary(
      practiceId: json['practice_id'] as String,
      practiceName: json['practice_name'] as String,
      openingHours: json['opening_hours'] as String?,
      averageWaitTimeMinutes: json['average_wait_time_minutes'] as int,
      nowServingTicket: json['now_serving_ticket'] as String?,
      queues: queuesJson
          .map((item) => PublicQueueSummaryItem.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList(),
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }
}
