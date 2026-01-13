import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';
import '../services/chat_service.dart';
import 'core_providers.dart';

/// Chat rooms provider
final chatRoomsProvider =
    FutureProvider.autoDispose<List<ChatRoom>>((ref) async {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getRooms();
});

/// Unread counts provider
final unreadCountsProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getUnreadCounts();
});

/// Total unread count
final totalUnreadProvider = Provider<int>((ref) {
  final unreadCounts = ref.watch(unreadCountsProvider);
  return unreadCounts.maybeWhen(
    data: (counts) => counts.values.fold(0, (a, b) => a + b),
    orElse: () => 0,
  );
});

/// Messages provider for a specific room
final roomMessagesProvider = FutureProvider.family
    .autoDispose<List<ChatMessage>, String>((ref, roomId) async {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getMessages(roomId: roomId);
});

/// Chat room notifier for managing chat operations
class ChatRoomNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final ChatService _chatService;
  final String _roomId;

  ChatRoomNotifier(this._chatService, this._roomId)
      : super(const AsyncValue.loading()) {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _chatService.getMessages(roomId: _roomId);
      state = AsyncValue.data(messages);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendMessage({
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
  }) async {
    final currentMessages =
        state.maybeWhen(data: (m) => m, orElse: () => <ChatMessage>[]);

    try {
      final message = await _chatService.sendMessage(
        roomId: _roomId,
        content: content,
        type: type,
        replyToMessageId: replyToMessageId,
      );
      state = AsyncValue.data([message, ...currentMessages]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> markAsRead(String messageId) async {
    await _chatService.markAsRead(roomId: _roomId, messageId: messageId);
  }

  Future<void> loadMore() async {
    final currentMessages =
        state.maybeWhen(data: (m) => m, orElse: () => <ChatMessage>[]);
    if (currentMessages.isEmpty) return;

    try {
      final olderMessages = await _chatService.getMessages(
        roomId: _roomId,
        beforeMessageId: currentMessages.last.id,
      );
      state = AsyncValue.data([...currentMessages, ...olderMessages]);
    } catch (e, st) {
      // Don't replace state on load more error
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _loadMessages();
}

/// Chat room notifier provider factory
final chatRoomNotifierProvider = StateNotifierProvider.family
    .autoDispose<ChatRoomNotifier, AsyncValue<List<ChatMessage>>, String>(
  (ref, roomId) {
    final chatService = ref.watch(chatServiceProvider);
    return ChatRoomNotifier(chatService, roomId);
  },
);
