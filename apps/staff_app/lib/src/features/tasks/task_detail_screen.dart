import 'package:flutter/material.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Task detail screen
class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aufgabe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'assign', child: Text('Zuweisen')),
              const PopupMenuItem(value: 'priority', child: Text('Priorität ändern')),
              const PopupMenuItem(value: 'delete', child: Text('Löschen')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and priority
            Row(
              children: [
                StatusBadge(
                  text: 'Offen',
                  color: AppColors.warning,
                  icon: Icons.pending,
                ),
                const SizedBox(width: 8),
                StatusBadge(
                  text: 'Hoch',
                  color: AppColors.error,
                  icon: Icons.arrow_upward,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Title
            Text('Blutabnahme vorbereiten', style: AppTextStyles.h4),
            const SizedBox(height: 24),
            // Description
            Text('Beschreibung', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Bitte bereiten Sie alles für die Blutabnahme bei Patient Müller in Raum 2 vor. '
                  'Der Patient ist nüchtern und benötigt ein großes Blutbild.',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Details
            Text('Details', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Erstellt von'),
                    subtitle: const Text('Dr. Schmidt'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Zugewiesen an'),
                    subtitle: const Text('MFA Müller'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Erstellt'),
                    subtitle: const Text('Heute, 10:30'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.room),
                    title: const Text('Raum'),
                    subtitle: const Text('Raum 2'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Related patient
            Text('Patient', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const AppAvatar(name: 'Max Müller'),
                title: const Text('Max Müller'),
                subtitle: const Text('Geb. 15.03.1985 • Ticket A33'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 24),
            // Comments
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kommentare', style: AppTextStyles.labelMedium),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Hinzufügen'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const AppAvatar(name: 'MFA Müller', size: 32),
                title: const Text('MFA Müller'),
                subtitle: const Text('Materialien sind bereit'),
                trailing: Text('10:35', style: AppTextStyles.labelSmall),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Weiterleiten'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check),
                label: const Text('Erledigt'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
