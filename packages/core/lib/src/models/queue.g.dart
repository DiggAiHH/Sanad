// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QueueCategoryImpl _$$QueueCategoryImplFromJson(Map<String, dynamic> json) => _$QueueCategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      prefix: json['prefix'] as String,
      description: json['description'] as String?,
      currentNumber: (json['currentNumber'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      color: json['color'] as String? ?? '#2196F3',
    );

Map<String, dynamic> _$$QueueCategoryImplToJson(_$QueueCategoryImpl instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'prefix': instance.prefix,
      'description': instance.description,
      'currentNumber': instance.currentNumber,
      'isActive': instance.isActive,
      'color': instance.color,
    };

_$QueueStateImpl _$$QueueStateImplFromJson(Map<String, dynamic> json) => _$QueueStateImpl(
      practiceId: json['practiceId'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => QueueCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      activeTickets: (json['activeTickets'] as List<dynamic>)
          .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalWaiting: (json['totalWaiting'] as num).toInt(),
      totalInProgress: (json['totalInProgress'] as num).toInt(),
      averageWaitMinutes: (json['averageWaitMinutes'] as num?)?.toInt(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$QueueStateImplToJson(_$QueueStateImpl instance) => <String, dynamic>{
      'practiceId': instance.practiceId,
      'categories': instance.categories.map((e) => e.toJson()).toList(),
      'activeTickets': instance.activeTickets.map((e) => e.toJson()).toList(),
      'totalWaiting': instance.totalWaiting,
      'totalInProgress': instance.totalInProgress,
      'averageWaitMinutes': instance.averageWaitMinutes,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
