import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Staff home screen with overview
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _lastUpdated = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const AppAvatar(name: 'Dr. Schmidt', size: 36),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Guten Tag, Dr. Schmidt', style: AppTextStyles.h6),
                Text(
                  'Hausarztpraxis Müller',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          Consumer(
            builder: (context, ref, _) {
              final mode = ref.watch(themeModeProvider);
              return ThemeModeMenuButton(
                mode: mode,
                onSelected: (next) =>
                    ref.read(themeModeProvider.notifier).setMode(next),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAsync,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Queue status
              const QueueStatus(
                waitingCount: 8,
                inProgressCount: 2,
                averageWaitMinutes: 12,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.update, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Aktualisiert: ${_formatTime(context, _lastUpdated)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Quick actions
              Text('Schnellzugriff', style: AppTextStyles.h5),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final actions = [
                    _buildQuickAction(
                      context,
                      icon: Icons.campaign,
                      label: 'Nächsten\naufrufen',
                      color: AppColors.primary,
                      onTap: () => _callNext(context),
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.chat,
                      label: 'Neue\nNachricht',
                      color: AppColors.secondary,
                      badgeCount: 3,
                      onTap: () => context.go('/chat'),
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.add_task,
                      label: 'Aufgabe\nerstellen',
                      color: AppColors.success,
                      onTap: () => _createTask(context),
                    ),
                  ];
                  if (constraints.maxWidth < 700) {
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: actions
                          .map((action) => SizedBox(
                                width: (constraints.maxWidth - 12) / 2,
                                child: action,
                              ))
                          .toList(),
                    );
                  }
                  return Row(
                    children: [
                      for (int i = 0; i < actions.length; i++) ...[
                        Expanded(child: actions[i]),
                        if (i != actions.length - 1) const SizedBox(width: 12),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              // Pending tasks
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Offene Aufgaben', style: AppTextStyles.h5),
                  TextButton(
                    onPressed: () => context.go('/tasks'),
                    child: const Text('Alle anzeigen'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(3, (index) => _buildTaskItem(context, index)),
              const SizedBox(height: 24),
              // Recent messages
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Neue Nachrichten', style: AppTextStyles.h5),
                  TextButton(
                    onPressed: () => context.go('/chat'),
                    child: const Text('Alle anzeigen'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(2, (index) => _buildChatItem(context, index)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Badge(
                  isLabelVisible: badgeCount != null,
                  label: Text(badgeCount?.toString() ?? ''),
                  child: Icon(icon, color: color, size: 28),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.labelMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, int index) {
    final priorities = ['high', 'medium', 'low'];
    final priority = priorities[index % 3];
    final colors = [AppColors.error, AppColors.warning, AppColors.success];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: colors[index % 3],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text('Aufgabe ${index + 1}'),
        subtitle: Text('Von: MFA Müller • ${10 + index * 5} Min.'),
        trailing: IconButton(
          icon: const Icon(Icons.check_circle_outline),
          onPressed: () {},
          color: AppColors.success,
        ),
        onTap: () => context.go('/tasks/task$index'),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, int index) {
    final names = ['MFA Team', 'Dr. Meier'];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: AppAvatar(name: names[index]),
        title: Text(names[index]),
        subtitle: const Text('Patient in Raum 2 benötigt...'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('vor ${5 + index * 3} Min.', style: AppTextStyles.labelSmall),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '2',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        onTap: () => context.go('/chat/room$index'),
      ),
    );
  }

  void _callNext(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nächster Patient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TicketDisplay(ticketNumber: 'A34'),
            const SizedBox(height: 16),
            const Text('Max Mustermann'),
            const Text('Allgemeine Untersuchung'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aufrufen'),
          ),
        ],
      ),
    );
  }

  void _createTask(BuildContext context) {
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
            Text('Neue Aufgabe', style: AppTextStyles.h5),
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Zuweisen an'),
              items: const [
                DropdownMenuItem(value: 'mfa1', child: Text('MFA Müller')),
                DropdownMenuItem(value: 'mfa2', child: Text('MFA Schmidt')),
                DropdownMenuItem(value: 'dr1', child: Text('Dr. Meier')),
              ],
              onChanged: (value) {},
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Erstellen'),
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

  Future<void> _refreshAsync() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _lastUpdated = DateTime.now());
    }
  }

  String _formatTime(BuildContext context, DateTime time) {
    final localizations = MaterialLocalizations.of(context);
    final timeOfDay = TimeOfDay.fromDateTime(time);
    return localizations.formatTimeOfDay(
      timeOfDay,
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
  }
}
