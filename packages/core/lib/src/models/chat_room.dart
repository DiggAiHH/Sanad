import 'package:freezed_annotation/freezed_annotation.dart';
import 'chat_message.dart';

part 'chat_room.freezed.dart';
part 'chat_room.g.dart';

/// Chat room type
enum ChatRoomType {
  @JsonValue('direct')
  direct,
  @JsonValue('group')
  group,
  @JsonValue('department')
  department,
  @JsonValue('broadcast')
  broadcast,
}

/// Chat room model
@freezed
class ChatRoom with _$ChatRoom {
  const factory ChatRoom({
    required String id,
    required String practiceId,
    required ChatRoomType type,
    String? name,
    String? avatarUrl,
    required List<String> memberIds,
    @Default([]) List<String> adminIds,
    ChatMessage? lastMessage,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(true) bool isActive,
  }) = _ChatRoom;

  factory ChatRoom.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomFromJson(json);
}

/// Unread count per room for a user
@freezed
class ChatRoomUnread with _$ChatRoomUnread {
  const factory ChatRoomUnread({
    required String roomId,
    required String oderId,
    required int unreadCount,
    DateTime? lastReadAt,
  }) = _ChatRoomUnread;

  factory ChatRoomUnread.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomUnreadFromJson(json);
}
