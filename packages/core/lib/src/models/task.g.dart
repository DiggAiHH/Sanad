// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskImpl _$$TaskImplFromJson(Map<String, dynamic> json) => _$TaskImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdById: json['createdById'] as String,
      assignedToId: json['assignedToId'] as String,
      patientId: json['patientId'] as String?,
      ticketId: json['ticketId'] as String?,
      priority: $enumDecode(_$TaskPriorityEnumMap, json['priority']),
      status: $enumDecode(_$TaskStatusEnumMap, json['status']),
      dueAt: json['dueAt'] == null ? null : DateTime.parse(json['dueAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] == null ? null : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null ? null : DateTime.parse(json['completedAt'] as String),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$TaskImplToJson(_$TaskImpl instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'createdById': instance.createdById,
      'assignedToId': instance.assignedToId,
      'patientId': instance.patientId,
      'ticketId': instance.ticketId,
      'priority': _$TaskPriorityEnumMap[instance.priority]!,
      'status': _$TaskStatusEnumMap[instance.status]!,
      'dueAt': instance.dueAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'tags': instance.tags,
      'notes': instance.notes,
    };

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'low',
  TaskPriority.medium: 'medium',
  TaskPriority.high: 'high',
  TaskPriority.critical: 'critical',
};

const _$TaskStatusEnumMap = {
  TaskStatus.pending: 'pending',
  TaskStatus.inProgress: 'in_progress',
  TaskStatus.completed: 'completed',
  TaskStatus.cancelled: 'cancelled',
};
