import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Chat list screen showing all conversations
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          // Groups section
          _buildSectionHeader('Gruppen'),
          _buildChatItem(
            context,
            roomId: 'team',
            name: 'Praxis-Team',
            avatar: 'PT',
            lastMessage: 'MFA Müller: Patient wartet...',
            time: 'vor 2 Min.',
            unreadCount: 3,
            isGroup: true,
          ),
          _buildChatItem(
            context,
            roomId: 'mfa',
            name: 'MFA-Gruppe',
            avatar: 'MFA',
            lastMessage: 'Wer kann Raum 2 übernehmen?',
            time: 'vor 15 Min.',
            unreadCount: 0,
            isGroup: true,
          ),
          // Direct messages section
          _buildSectionHeader('Direktnachrichten'),
          _buildChatItem(
            context,
            roomId: 'dr1',
            name: 'Dr. Meier',
            lastMessage: 'Können Sie kurz in Raum 3?',
            time: 'vor 5 Min.',
            unreadCount: 1,
          ),
          _buildChatItem(
            context,
            roomId: 'mfa1',
            name: 'MFA Müller',
            lastMessage: 'Blutabnahme fertig',
            time: 'vor 20 Min.',
            unreadCount: 0,
          ),
          _buildChatItem(
            context,
            roomId: 'mfa2',
            name: 'MFA Schmidt',
            lastMessage: 'Ok, erledigt!',
            time: 'vor 1 Std.',
            unreadCount: 0,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewChatDialog(context),
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: AppTextStyles.labelMedium),
    );
  }

  Widget _buildChatItem(
    BuildContext context, {
    required String roomId,
    required String name,
    String? avatar,
    required String lastMessage,
    required String time,
    required int unreadCount,
    bool isGroup = false,
  }) {
    return ListTile(
      leading: isGroup
          ? Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.group, color: AppColors.secondary),
            )
          : AppAvatar(name: name),
      title: Text(name, style: AppTextStyles.labelLarge),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(time, style: AppTextStyles.labelSmall),
          const SizedBox(height: 4),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      onTap: () => context.go('/chat/$roomId'),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text('Neue Gruppe'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Direktnachricht'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
