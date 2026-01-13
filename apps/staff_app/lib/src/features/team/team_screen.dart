import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Team overview screen
class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Online section
          _buildSectionHeader('Online (4)'),
          _buildStaffItem(
            context,
            name: 'Dr. Meier',
            role: 'Arzt',
            room: 'Raum 1',
            isOnline: true,
          ),
          _buildStaffItem(
            context,
            name: 'MFA Müller',
            role: 'Med. Fachangestellte',
            room: 'Empfang',
            isOnline: true,
          ),
          _buildStaffItem(
            context,
            name: 'MFA Schmidt',
            role: 'Med. Fachangestellte',
            room: 'Raum 3',
            isOnline: true,
          ),
          _buildStaffItem(
            context,
            name: 'MFA Weber',
            role: 'Med. Fachangestellte',
            room: 'Labor',
            isOnline: true,
          ),
          const SizedBox(height: 16),
          // Offline section
          _buildSectionHeader('Offline (2)'),
          _buildStaffItem(
            context,
            name: 'Dr. Schmidt',
            role: 'Arzt',
            room: '-',
            isOnline: false,
          ),
          _buildStaffItem(
            context,
            name: 'MFA Bauer',
            role: 'Med. Fachangestellte',
            room: '-',
            isOnline: false,
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

  Widget _buildStaffItem(
    BuildContext context, {
    required String name,
    required String role,
    required String room,
    required bool isOnline,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Stack(
          children: [
            AppAvatar(name: name),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.success : AppColors.textSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(name, style: AppTextStyles.labelLarge),
        subtitle: Row(
          children: [
            Text(role),
            if (room != '-') ...[
              const Text(' • '),
              Text(room),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () => context.go('/chat/$name'),
              color: AppColors.primary,
            ),
            IconButton(
              icon: const Icon(Icons.add_task),
              onPressed: () => _assignTask(context, name),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Aufgabe an $staffName gesendet')),
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
}
