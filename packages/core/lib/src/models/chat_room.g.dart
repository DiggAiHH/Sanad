// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatRoomImpl _$$ChatRoomImplFromJson(Map<String, dynamic> json) =>
    _$ChatRoomImpl(
      id: json['id'] as String,
      practiceId: json['practiceId'] as String,
      type: $enumDecode(_$ChatRoomTypeEnumMap, json['type']),
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      memberIds:
          (json['memberIds'] as List<dynamic>).map((e) => e as String).toList(),
      adminIds: (json['adminIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lastMessage: json['lastMessage'] == null
          ? null
          : ChatMessage.fromJson(json['lastMessage'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$ChatRoomImplToJson(_$ChatRoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'practiceId': instance.practiceId,
      'type': _$ChatRoomTypeEnumMap[instance.type]!,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'memberIds': instance.memberIds,
      'adminIds': instance.adminIds,
      'lastMessage': instance.lastMessage,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isActive': instance.isActive,
    };

const _$ChatRoomTypeEnumMap = {
  ChatRoomType.direct: 'direct',
  ChatRoomType.group: 'group',
  ChatRoomType.department: 'department',
  ChatRoomType.broadcast: 'broadcast',
};

_$ChatRoomUnreadImpl _$$ChatRoomUnreadImplFromJson(Map<String, dynamic> json) =>
    _$ChatRoomUnreadImpl(
      roomId: json['roomId'] as String,
      oderId: json['oderId'] as String,
      unreadCount: (json['unreadCount'] as num).toInt(),
      lastReadAt: json['lastReadAt'] == null
          ? null
          : DateTime.parse(json['lastReadAt'] as String),
    );

Map<String, dynamic> _$$ChatRoomUnreadImplToJson(
        _$ChatRoomUnreadImpl instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'oderId': instance.oderId,
      'unreadCount': instance.unreadCount,
      'lastReadAt': instance.lastReadAt?.toIso8601String(),
    };
