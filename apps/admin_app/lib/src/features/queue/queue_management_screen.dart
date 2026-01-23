import 'package:flutter/material.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Queue management screen for admin
class QueueManagementScreen extends StatefulWidget {
  const QueueManagementScreen({super.key});

  @override
  State<QueueManagementScreen> createState() => _QueueManagementScreenState();
}

class _QueueManagementScreenState extends State<QueueManagementScreen> {
  String _selectedStatus = 'Wartend';
  String _query = '';
  DateTime _lastUpdated = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final tickets = _filteredTickets();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warteschlangen-Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
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
            const SizedBox(height: 16),
            _buildLastUpdated(context),
            const SizedBox(height: 16),
            // Queue categories management
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 1000) {
                    return Column(
                      children: [
                        _buildCategoriesCard(),
                        const SizedBox(height: 16),
                        Expanded(child: _buildActiveTicketsCard(tickets)),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: _buildCategoriesCard()),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: _buildActiveTicketsCard(tickets)),
                    ],
                  );
                },
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final list = ListView.builder(
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
            );

            final listChild = constraints.hasBoundedHeight
                ? Expanded(child: list)
                : ListView.builder(
                    itemCount: categories.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                  );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kategorien', style: AppTextStyles.h5),
                const SizedBox(height: 16),
                listChild,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActiveTicketsCard(List<_ActiveTicket> tickets) {
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
                Text(
                  'Anzahl: ${tickets.length}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SearchInput(
              hint: 'Ticket oder Patient suchen...',
              onChanged: (value) => setState(() => _query = value.trim()),
              onClear: () => setState(() => _query = ''),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('Wartend'),
                _buildFilterChip('Aufgerufen'),
                _buildFilterChip('In Behandlung'),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: tickets.isEmpty
                  ? EmptyStateWidget.noData(
                      title: 'Keine Tickets',
                      subtitle: 'Für diesen Status sind keine Tickets vorhanden.',
                      actionLabel: 'Filter zurücksetzen',
                      onAction: () => setState(() {
                        _selectedStatus = 'Wartend';
                        _query = '';
                      }),
                    )
                  : ListView.builder(
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = tickets[index];
                        return _buildTicketRow(ticket);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedStatus == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (value) {
        if (!value) return;
        setState(() => _selectedStatus = label);
      },
    );
  }

  Widget _buildTicketRow(_ActiveTicket ticket) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: ticket.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ticket.color),
        ),
        child: Text(
          ticket.number,
          style: AppTextStyles.h6.copyWith(color: ticket.color),
        ),
      ),
      title: Text(ticket.patientName),
      subtitle: Text('Wartet seit ${ticket.waitMinutes} Min.'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusBadge(text: ticket.status, color: ticket.color),
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

  void _refresh() {
    setState(() => _lastUpdated = DateTime.now());
  }

  Widget _buildLastUpdated(BuildContext context) {
    return Row(
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
    );
  }

  String _formatTime(BuildContext context, DateTime time) {
    final localizations = MaterialLocalizations.of(context);
    final timeOfDay = TimeOfDay.fromDateTime(time);
    return localizations.formatTimeOfDay(
      timeOfDay,
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
  }

  List<_ActiveTicket> _filteredTickets() {
    final allTickets = _demoTickets();
    return allTickets.where((ticket) {
      final matchesStatus = ticket.status == _selectedStatus;
      final matchesQuery = _query.isEmpty ||
          ticket.number.toLowerCase().contains(_query.toLowerCase()) ||
          ticket.patientName.toLowerCase().contains(_query.toLowerCase());
      return matchesStatus && matchesQuery;
    }).toList();
  }

  List<_ActiveTicket> _demoTickets() {
    return [
      _ActiveTicket('A33', 'Wartend', AppColors.waiting, 6, 'Max Mustermann'),
      _ActiveTicket('B12', 'Wartend', AppColors.waiting, 10, 'Lea Hoffmann'),
      _ActiveTicket('C07', 'Aufgerufen', AppColors.called, 4, 'Ahmet Yilmaz'),
      _ActiveTicket('D21', 'In Behandlung', AppColors.inProgress, 12, 'Maria Keller'),
      _ActiveTicket('A34', 'Wartend', AppColors.waiting, 9, 'Jonas Weber'),
      _ActiveTicket('B13', 'Aufgerufen', AppColors.called, 7, 'Lina Becker'),
      _ActiveTicket('C08', 'In Behandlung', AppColors.inProgress, 14, 'David Roth'),
      _ActiveTicket('D22', 'Wartend', AppColors.waiting, 3, 'Sara Klein'),
    ];
  }
}

class _ActiveTicket {
  final String number;
  final String status;
  final Color color;
  final int waitMinutes;
  final String patientName;

  const _ActiveTicket(
    this.number,
    this.status,
    this.color,
    this.waitMinutes,
    this.patientName,
  );
}
