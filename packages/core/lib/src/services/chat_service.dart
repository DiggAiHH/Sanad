import '../models/chat_message.dart';
import '../models/chat_room.dart';
import 'api_service.dart';

/// Chat service for staff communication
class ChatService {
  final ApiService _api;

  ChatService({required ApiService apiService}) : _api = apiService;

  /// Get all chat rooms for current user
  Future<List<ChatRoom>> getRooms() async {
    final response = await _api.get('/chat/rooms');
    return (response.data as List)
        .map((e) => ChatRoom.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get or create direct chat room
  Future<ChatRoom> getOrCreateDirectRoom(String otherUserId) async {
    final response = await _api.post(
      '/chat/rooms/direct',
      data: {'user_id': otherUserId},
    );
    return ChatRoom.fromJson(response.data as Map<String, dynamic>);
  }

  /// Create group chat room
  Future<ChatRoom> createGroupRoom({
    required String name,
    required List<String> memberIds,
  }) async {
    final response = await _api.post(
      '/chat/rooms/group',
      data: {
        'name': name,
        'member_ids': memberIds,
      },
    );
    return ChatRoom.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get messages for a room
  Future<List<ChatMessage>> getMessages({
    required String roomId,
    int limit = 50,
    String? beforeMessageId,
  }) async {
    final response = await _api.get(
      '/chat/rooms/$roomId/messages',
      queryParameters: {
        'limit': limit,
        if (beforeMessageId != null) 'before': beforeMessageId,
      },
    );
    return (response.data as List)
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Send a text message
  Future<ChatMessage> sendMessage({
    required String roomId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
  }) async {
    final response = await _api.post(
      '/chat/rooms/$roomId/messages',
      data: {
        'content': content,
        'type': type.name,
        if (replyToMessageId != null) 'reply_to': replyToMessageId,
      },
    );
    return ChatMessage.fromJson(response.data as Map<String, dynamic>);
  }

  /// Mark messages as read
  Future<void> markAsRead({
    required String roomId,
    required String messageId,
  }) async {
    await _api.post('/chat/rooms/$roomId/messages/$messageId/read');
  }

  /// Delete a message
  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
  }) async {
    await _api.delete('/chat/rooms/$roomId/messages/$messageId');
  }

  /// Get unread counts
  Future<Map<String, int>> getUnreadCounts() async {
    final response = await _api.get('/chat/unread');
    return Map<String, int>.from(response.data as Map);
  }
}
