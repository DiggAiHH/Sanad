import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Chat list screen showing all conversations
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String _query = '';
  DateTime _lastUpdated = DateTime.now();

  final List<_ChatItem> _items = const [
    _ChatItem(
      roomId: 'team',
      name: 'Praxis-Team',
      lastMessage: 'MFA Müller: Patient wartet...',
      time: 'vor 2 Min.',
      unreadCount: 3,
      isGroup: true,
    ),
    _ChatItem(
      roomId: 'mfa',
      name: 'MFA-Gruppe',
      lastMessage: 'Wer kann Raum 2 übernehmen?',
      time: 'vor 15 Min.',
      unreadCount: 0,
      isGroup: true,
    ),
    _ChatItem(
      roomId: 'dr1',
      name: 'Dr. Meier',
      lastMessage: 'Können Sie kurz in Raum 3?',
      time: 'vor 5 Min.',
      unreadCount: 1,
      isGroup: false,
    ),
    _ChatItem(
      roomId: 'mfa1',
      name: 'MFA Müller',
      lastMessage: 'Blutabnahme fertig',
      time: 'vor 20 Min.',
      unreadCount: 0,
      isGroup: false,
    ),
    _ChatItem(
      roomId: 'mfa2',
      name: 'MFA Schmidt',
      lastMessage: 'Ok, erledigt!',
      time: 'vor 1 Std.',
      unreadCount: 0,
      isGroup: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems();
    final groups = filtered.where((item) => item.isGroup).toList();
    final directs = filtered.where((item) => !item.isGroup).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Aktualisieren',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          SearchInput(
            hint: 'Chats durchsuchen...',
            onChanged: (value) => setState(() => _query = value.trim()),
            onClear: () => setState(() => _query = ''),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ergebnisse: ${filtered.length}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              _buildLastUpdated(context),
            ],
          ),
          const SizedBox(height: 12),
          ScreenState(
            isEmpty: filtered.isEmpty,
            emptyTitle: 'Keine Chats gefunden',
            emptySubtitle: 'Versuchen Sie eine andere Suche.',
            emptyActionLabel: 'Suche löschen',
            onAction: () => setState(() => _query = ''),
            child: Column(
              children: [
                if (groups.isNotEmpty) ...[
                  _buildSectionHeader('Gruppen'),
                  ...groups.map((item) => _buildChatItem(context, item)),
                ],
                if (directs.isNotEmpty) ...[
                  _buildSectionHeader('Direktnachrichten'),
                  ...directs.map((item) => _buildChatItem(context, item)),
                ],
              ],
            ),
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

  Widget _buildLastUpdated(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final timeOfDay = TimeOfDay.fromDateTime(_lastUpdated);
    final formatted = localizations.formatTimeOfDay(
      timeOfDay,
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
    return Row(
      children: [
        const Icon(Icons.update, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          'Aktualisiert: $formatted',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildChatItem(BuildContext context, _ChatItem item) {
    return ListTile(
      leading: item.isGroup
          ? Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.group, color: AppColors.secondary),
            )
          : AppAvatar(name: item.name),
      title: Text(item.name, style: AppTextStyles.labelLarge),
      subtitle: Text(
        item.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: item.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(item.time, style: AppTextStyles.labelSmall),
          const SizedBox(height: 4),
          if (item.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                item.unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      onTap: () => context.go('/chat/${item.roomId}'),
    );
  }

  List<_ChatItem> _filteredItems() {
    if (_query.isEmpty) {
      return _items;
    }
    final lowered = _query.toLowerCase();
    return _items.where((item) {
      return item.name.toLowerCase().contains(lowered) ||
          item.lastMessage.toLowerCase().contains(lowered);
    }).toList();
  }

  void _refresh() {
    setState(() => _lastUpdated = DateTime.now());
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

class _ChatItem {
  final String roomId;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isGroup;

  const _ChatItem({
    required this.roomId,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.isGroup,
  });
}
