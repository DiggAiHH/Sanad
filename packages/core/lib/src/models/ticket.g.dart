// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TicketImpl _$$TicketImplFromJson(Map<String, dynamic> json) => _$TicketImpl(
      id: json['id'] as String,
      ticketNumber: json['ticketNumber'] as String,
      prefix: json['prefix'] as String,
      number: (json['number'] as num).toInt(),
      patientId: json['patientId'] as String,
      practiceId: json['practiceId'] as String,
      assignedStaffId: json['assignedStaffId'] as String?,
      roomNumber: json['roomNumber'] as String?,
      status: $enumDecode(_$TicketStatusEnumMap, json['status']),
      priority: $enumDecodeNullable(_$TicketPriorityEnumMap, json['priority']) ?? TicketPriority.normal,
      visitReason: json['visitReason'] as String?,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      calledAt: json['calledAt'] == null ? null : DateTime.parse(json['calledAt'] as String),
      startedAt: json['startedAt'] == null ? null : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null ? null : DateTime.parse(json['completedAt'] as String),
      estimatedWaitMinutes: (json['estimatedWaitMinutes'] as num?)?.toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$TicketImplToJson(_$TicketImpl instance) => <String, dynamic>{
      'id': instance.id,
      'ticketNumber': instance.ticketNumber,
      'prefix': instance.prefix,
      'number': instance.number,
      'patientId': instance.patientId,
      'practiceId': instance.practiceId,
      'assignedStaffId': instance.assignedStaffId,
      'roomNumber': instance.roomNumber,
      'status': _$TicketStatusEnumMap[instance.status]!,
      'priority': _$TicketPriorityEnumMap[instance.priority]!,
      'visitReason': instance.visitReason,
      'issuedAt': instance.issuedAt.toIso8601String(),
      'calledAt': instance.calledAt?.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'estimatedWaitMinutes': instance.estimatedWaitMinutes,
      'notes': instance.notes,
    };

const _$TicketStatusEnumMap = {
  TicketStatus.waiting: 'waiting',
  TicketStatus.called: 'called',
  TicketStatus.inProgress: 'in_progress',
  TicketStatus.completed: 'completed',
  TicketStatus.cancelled: 'cancelled',
  TicketStatus.noShow: 'no_show',
};

const _$TicketPriorityEnumMap = {
  TicketPriority.normal: 'normal',
  TicketPriority.urgent: 'urgent',
  TicketPriority.emergency: 'emergency',
};
