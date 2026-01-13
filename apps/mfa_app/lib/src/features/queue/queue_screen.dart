import 'package:flutter/material.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Queue management screen for MFA
class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warteschlange'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
            tooltip: 'Aktualisieren',
          ),
        ],
      ),
      body: Column(
        children: [
          // Queue status
          const Padding(
            padding: EdgeInsets.all(16),
            child: QueueStatus(
              waitingCount: 8,
              inProgressCount: 2,
              averageWaitMinutes: 12,
            ),
          ),
          // Filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Alle', true),
                const SizedBox(width: 8),
                _buildFilterChip('A', false, color: AppColors.primary),
                const SizedBox(width: 8),
                _buildFilterChip('B', false, color: AppColors.error),
                const SizedBox(width: 8),
                _buildFilterChip('C', false, color: AppColors.success),
                const SizedBox(width: 8),
                _buildFilterChip('D', false, color: AppColors.warning),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Ticket list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 10,
              itemBuilder: (context, index) => _buildTicketItem(context, index),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _callNext(context),
        icon: const Icon(Icons.campaign),
        label: const Text('Nächsten aufrufen'),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, {Color? color}) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      selectedColor: color?.withOpacity(0.2),
      checkmarkColor: color,
      onSelected: (value) {},
    );
  }

  Widget _buildTicketItem(BuildContext context, int index) {
    final prefixes = ['A', 'B', 'C', 'D'];
    final prefix = prefixes[index % prefixes.length];
    final number = 30 + index;
    final ticketNumber = '$prefix$number';
    final colors = [AppColors.primary, AppColors.error, AppColors.success, AppColors.warning];
    final color = colors[index % colors.length];
    final statuses = ['waiting', 'waiting', 'called', 'waiting'];
    final status = statuses[index % statuses.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              ticketNumber,
              style: AppTextStyles.h6.copyWith(color: color),
            ),
          ),
        ),
        title: Text('Patient ${index + 1}'),
        subtitle: Row(
          children: [
            const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('Wartet seit ${5 + index * 2} Min.'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == 'called')
              StatusBadge.info('Aufgerufen', icon: Icons.campaign)
            else
              StatusBadge(
                text: 'Wartend',
                color: AppColors.waiting,
              ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'call', child: Text('Aufrufen')),
                const PopupMenuItem(value: 'priority', child: Text('Priorität ändern')),
                const PopupMenuItem(value: 'transfer', child: Text('Übertragen')),
                const PopupMenuItem(value: 'cancel', child: Text('Abbrechen')),
              ],
              onSelected: (value) {},
            ),
          ],
        ),
        onTap: () => _showTicketDetails(context, ticketNumber),
      ),
    );
  }

  void _callNext(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nächsten aufrufen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Welche Kategorie?'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildCategoryButton('A', AppColors.primary),
                _buildCategoryButton('B', AppColors.error),
                _buildCategoryButton('C', AppColors.success),
                _buildCategoryButton('D', AppColors.warning),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String prefix, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      child: Text(prefix, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  void _showTicketDetails(BuildContext context, String ticketNumber) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TicketDisplay(ticketNumber: ticketNumber),
            const SizedBox(height: 24),
            const ListTile(
              leading: Icon(Icons.person),
              title: Text('Max Mustermann'),
              subtitle: Text('Geb. 15.03.1985'),
            ),
            const ListTile(
              leading: Icon(Icons.medical_services),
              title: Text('Besuchsgrund'),
              subtitle: Text('Allgemeine Untersuchung'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Schließen'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.campaign),
                    label: const Text('Aufrufen'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
