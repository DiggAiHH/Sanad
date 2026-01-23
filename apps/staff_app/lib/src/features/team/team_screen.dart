import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Team overview screen
class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  String _query = '';
  DateTime _lastUpdated = DateTime.now();

  final List<_StaffMember> _members = const [
    _StaffMember(name: 'Dr. Meier', role: 'Arzt', room: 'Raum 1', isOnline: true),
    _StaffMember(name: 'MFA Müller', role: 'Med. Fachangestellte', room: 'Empfang', isOnline: true),
    _StaffMember(name: 'MFA Schmidt', role: 'Med. Fachangestellte', room: 'Raum 3', isOnline: true),
    _StaffMember(name: 'MFA Weber', role: 'Med. Fachangestellte', room: 'Labor', isOnline: true),
    _StaffMember(name: 'Dr. Schmidt', role: 'Arzt', room: '-', isOnline: false),
    _StaffMember(name: 'MFA Bauer', role: 'Med. Fachangestellte', room: '-', isOnline: false),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredMembers();
    final online = filtered.where((member) => member.isOnline).toList();
    final offline = filtered.where((member) => !member.isOnline).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Aktualisieren',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SearchInput(
            hint: 'Team durchsuchen...',
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
            emptyTitle: 'Niemand gefunden',
            emptySubtitle: 'Bitte passen Sie die Suche an.',
            emptyActionLabel: 'Suche löschen',
            onAction: () => setState(() => _query = ''),
            child: Column(
              children: [
                if (online.isNotEmpty) ...[
                  _buildSectionHeader('Online (${online.length})'),
                  ...online.map((member) => _buildStaffItem(context, member)),
                ],
                if (offline.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSectionHeader('Offline (${offline.length})'),
                  ...offline.map((member) => _buildStaffItem(context, member)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildStaffItem(BuildContext context, _StaffMember member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Stack(
          children: [
            AppAvatar(name: member.name),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: member.isOnline ? AppColors.success : AppColors.textSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(member.name, style: AppTextStyles.labelLarge),
        subtitle: Row(
          children: [
            Text(member.role),
            if (member.room != '-') ...[
              const Text(' • '),
              Text(member.room),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () => context.go('/chat/${member.name}'),
              color: AppColors.primary,
            ),
            IconButton(
              icon: const Icon(Icons.add_task),
              onPressed: () => _assignTask(context, member.name),
              color: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }

  void _assignTask(BuildContext context, String staffName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aufgabe an $staffName', style: AppTextStyles.h5),
            const SizedBox(height: 16),
            const TextInput(
              label: 'Titel',
              hint: 'Was soll erledigt werden?',
            ),
            const SizedBox(height: 16),
            const TextInput(
              label: 'Beschreibung',
              hint: 'Details...',
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Abbrechen'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ModernSnackBar.show(
                        context,
                        message: 'Aufgabe an $staffName gesendet',
                        type: SnackBarType.success,
                      );
                    },
                    child: const Text('Senden'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<_StaffMember> _filteredMembers() {
    if (_query.isEmpty) {
      return _members;
    }
    final lowered = _query.toLowerCase();
    return _members.where((member) {
      return member.name.toLowerCase().contains(lowered) ||
          member.role.toLowerCase().contains(lowered) ||
          member.room.toLowerCase().contains(lowered);
    }).toList();
  }

  void _refresh() {
    setState(() => _lastUpdated = DateTime.now());
  }
}

class _StaffMember {
  final String name;
  final String role;
  final String room;
  final bool isOnline;

  const _StaffMember({
    required this.name,
    required this.role,
    required this.room,
    required this.isOnline,
  });
}
