import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

/// Message type
enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('file')
  file,
  @JsonValue('voice')
  voice,
  @JsonValue('system')
  system,
  @JsonValue('task_assignment')
  taskAssignment,
}

/// Message status
enum MessageStatus {
  @JsonValue('sending')
  sending,
  @JsonValue('sent')
  sent,
  @JsonValue('delivered')
  delivered,
  @JsonValue('read')
  read,
  @JsonValue('failed')
  failed,
}

/// Chat message model
@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String roomId,
    required String senderId,
    required MessageType type,
    required String content,
    String? attachmentUrl,
    String? attachmentName,
    String? replyToMessageId,
    required MessageStatus status,
    @Default([]) List<String> readBy,
    required DateTime createdAt,
    DateTime? editedAt,
    @Default(false) bool isDeleted,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

extension ChatMessageExtension on ChatMessage {
  bool isReadBy(String userId) => readBy.contains(userId);
  bool get isEdited => editedAt != null;
}
