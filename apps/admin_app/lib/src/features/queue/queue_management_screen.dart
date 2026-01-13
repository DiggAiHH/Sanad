import 'package:flutter/material.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Queue management screen for admin
class QueueManagementScreen extends StatelessWidget {
  const QueueManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warteschlangen-Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
            tooltip: 'Aktualisieren',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Queue status overview
            const QueueStatus(
              waitingCount: 12,
              inProgressCount: 3,
              averageWaitMinutes: 15,
            ),
            const SizedBox(height: 24),
            // Queue categories management
            Expanded(
              child: Row(
                children: [
                  // Categories
                  Expanded(
                    child: _buildCategoriesCard(),
                  ),
                  const SizedBox(width: 16),
                  // Active tickets
                  Expanded(
                    flex: 2,
                    child: _buildActiveTicketsCard(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Kategorie hinzufügen'),
      ),
    );
  }

  Widget _buildCategoriesCard() {
    final categories = [
      {'name': 'Allgemein', 'prefix': 'A', 'color': AppColors.primary, 'count': 5},
      {'name': 'Blutabnahme', 'prefix': 'B', 'color': AppColors.error, 'count': 3},
      {'name': 'Impfung', 'prefix': 'C', 'color': AppColors.success, 'count': 2},
      {'name': 'Rezept', 'prefix': 'D', 'color': AppColors.warning, 'count': 2},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kategorien', style: AppTextStyles.h5),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (cat['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: cat['color'] as Color),
                      ),
                      child: Center(
                        child: Text(
                          cat['prefix'] as String,
                          style: AppTextStyles.h6.copyWith(color: cat['color'] as Color),
                        ),
                      ),
                    ),
                    title: Text(cat['name'] as String),
                    subtitle: Text('${cat['count']} wartend'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTicketsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Aktive Tickets', style: AppTextStyles.h5),
                Row(
                  children: [
                    _buildFilterChip('Wartend', true),
                    const SizedBox(width: 8),
                    _buildFilterChip('Aufgerufen', false),
                    const SizedBox(width: 8),
                    _buildFilterChip('In Behandlung', false),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 8,
                itemBuilder: (context, index) {
                  final prefixes = ['A', 'B', 'C', 'D'];
                  final prefix = prefixes[index % prefixes.length];
                  final number = 30 + index;
                  return _buildTicketRow('$prefix$number', index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (value) {},
    );
  }

  Widget _buildTicketRow(String ticketNumber, int index) {
    final statuses = ['Wartend', 'Aufgerufen', 'In Behandlung'];
    final status = statuses[index % 3];
    final colors = [AppColors.waiting, AppColors.called, AppColors.inProgress];
    final color = colors[index % 3];

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Text(
          ticketNumber,
          style: AppTextStyles.h6.copyWith(color: color),
        ),
      ),
      title: Text('Patient ${index + 1}'),
      subtitle: Text('Wartet seit ${5 + index * 2} Min.'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusBadge(text: status, color: color),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.campaign),
            onPressed: () {},
            tooltip: 'Aufrufen',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {},
            tooltip: 'Abbrechen',
          ),
        ],
      ),
    );
  }
}
