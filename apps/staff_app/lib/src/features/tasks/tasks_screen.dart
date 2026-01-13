import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Tasks list screen
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aufgaben'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Offen (5)'),
            Tab(text: 'In Arbeit (2)'),
            Tab(text: 'Erledigt'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList('pending'),
          _buildTaskList('in_progress'),
          _buildTaskList('completed'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createTask(context),
        icon: const Icon(Icons.add),
        label: const Text('Neue Aufgabe'),
      ),
    );
  }

  Widget _buildTaskList(String status) {
    final tasks = _getTasks(status);

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Keine Aufgaben',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => context.go('/tasks/${task['id']}'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildPriorityIndicator(task['priority'] as String),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task['title'] as String,
                          style: AppTextStyles.labelLarge,
                        ),
                      ),
                      if (status != 'completed')
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline),
                          onPressed: () {},
                          color: AppColors.success,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task['description'] as String,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('Von: ${task['from']}', style: AppTextStyles.labelSmall),
                      const Spacer(),
                      const Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(task['time'] as String, style: AppTextStyles.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriorityIndicator(String priority) {
    Color color;
    IconData icon;
    switch (priority) {
      case 'critical':
        color = AppColors.error;
        icon = Icons.priority_high;
        break;
      case 'high':
        color = AppColors.warning;
        icon = Icons.arrow_upward;
        break;
      default:
        color = AppColors.success;
        icon = Icons.remove;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  List<Map<String, dynamic>> _getTasks(String status) {
    if (status == 'pending') {
      return [
        {'id': '1', 'title': 'Blutabnahme vorbereiten', 'description': 'Raum 2, Patient Müller, nüchtern', 'from': 'Dr. Schmidt', 'time': 'vor 10 Min.', 'priority': 'high'},
        {'id': '2', 'title': 'EKG durchführen', 'description': 'Patient in Raum 3', 'from': 'Dr. Meier', 'time': 'vor 15 Min.', 'priority': 'critical'},
        {'id': '3', 'title': 'Rezept ausstellen', 'description': 'Für Patient Schmidt, Blutdruckmedikation', 'from': 'MFA Müller', 'time': 'vor 20 Min.', 'priority': 'normal'},
        {'id': '4', 'title': 'Überweisung vorbereiten', 'description': 'Kardiologie für Patient Weber', 'from': 'Dr. Schmidt', 'time': 'vor 30 Min.', 'priority': 'normal'},
        {'id': '5', 'title': 'Impfpass aktualisieren', 'description': 'Patient Fischer, Grippe-Impfung', 'from': 'MFA Schmidt', 'time': 'vor 45 Min.', 'priority': 'normal'},
      ];
    } else if (status == 'in_progress') {
      return [
        {'id': '6', 'title': 'Laborergebnisse prüfen', 'description': 'Patient Bauer, Blutbild', 'from': 'Labor', 'time': 'vor 5 Min.', 'priority': 'high'},
        {'id': '7', 'title': 'Rückruf Patient Meyer', 'description': 'Termin für nächste Woche', 'from': 'MFA Müller', 'time': 'vor 10 Min.', 'priority': 'normal'},
      ];
    }
    return [];
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
            const TextInput(label: 'Titel', hint: 'Was soll erledigt werden?'),
            const SizedBox(height: 16),
            const TextInput(label: 'Beschreibung', hint: 'Details...', maxLines: 3),
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Priorität'),
              items: const [
                DropdownMenuItem(value: 'normal', child: Text('Normal')),
                DropdownMenuItem(value: 'high', child: Text('Hoch')),
                DropdownMenuItem(value: 'critical', child: Text('Dringend')),
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
}
