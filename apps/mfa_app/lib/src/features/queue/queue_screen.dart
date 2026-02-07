import 'package:flutter/material.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Queue management screen for MFA
class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  String _selectedFilter = 'Alle';
  String _query = '';
  DateTime _lastUpdated = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final tickets = _filteredTickets();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warteschlange'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Aktualisieren',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAsync,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            const QueueStatus(
              waitingCount: 8,
              inProgressCount: 2,
              averageWaitMinutes: 12,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.update, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Aktualisiert: ${_formatTime(context, _lastUpdated)}',
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
            _buildFilterRow(tickets.length),
            const SizedBox(height: 16),
            ScreenState(
              isEmpty: tickets.isEmpty,
              emptyTitle: 'Keine Tickets',
              emptySubtitle: 'Für diese Kategorie sind aktuell keine Tickets vorhanden.',
              emptyActionLabel: 'Filter zurücksetzen',
              onAction: () => setState(() => _selectedFilter = 'Alle'),
              child: Column(
                children: [
                  ...tickets.map(
                    (ticket) => _buildTicketItem(
                      context,
                      ticket.number,
                      ticket.color,
                      ticket.status,
                      ticket.waitMinutes,
                      ticket.patientName,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _callNext(context),
        icon: const Icon(Icons.campaign),
        label: const Text('Nächsten aufrufen'),
      ),
    );
  }

  Widget _buildFilterRow(int resultCount) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 4),
          child: Text(
            'Ergebnisse: $resultCount',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        _buildFilterChip('Alle', color: AppColors.primary),
        _buildFilterChip('A', color: AppColors.primary),
        _buildFilterChip('B', color: AppColors.error),
        _buildFilterChip('C', color: AppColors.success),
        _buildFilterChip('D', color: AppColors.warning),
      ],
    );
  }

  Widget _buildFilterChip(String label, {Color? color}) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color?.withOpacity(0.2),
      checkmarkColor: color,
      onSelected: (_) => setState(() => _selectedFilter = label),
    );
  }

  Widget _buildTicketItem(
    BuildContext context,
    String ticketNumber,
    Color color,
    String status,
    int waitMinutes,
    String patientName,
  ) {
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
        title: Text(patientName),
        subtitle: Row(
          children: [
            const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('Wartet seit $waitMinutes Min.'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == 'called')
              StatusBadge.info('Aufgerufen', icon: Icons.campaign)
            else
              const StatusBadge(
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

  void _refresh() {
    setState(() => _lastUpdated = DateTime.now());
  }

  Future<void> _refreshAsync() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _refresh();
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

  List<_QueueTicket> _filteredTickets() {
    final tickets = _demoTickets();
    if (_selectedFilter == 'Alle') {
      return _filterByQuery(tickets);
    }
    return _filterByQuery(
      tickets.where((ticket) => ticket.number.startsWith(_selectedFilter)).toList(),
    );
  }

  List<_QueueTicket> _filterByQuery(List<_QueueTicket> tickets) {
    if (_query.isEmpty) return tickets;
    final q = _query.toLowerCase();
    return tickets.where((ticket) {
      return ticket.number.toLowerCase().contains(q) ||
          ticket.patientName.toLowerCase().contains(q);
    }).toList();
  }

  List<_QueueTicket> _demoTickets() {
    return [
      _QueueTicket('A33', AppColors.primary, 'waiting', 8, 'Max Mustermann'),
      _QueueTicket('B12', AppColors.error, 'waiting', 12, 'Lea Hoffmann'),
      _QueueTicket('C07', AppColors.success, 'called', 4, 'Ahmet Yilmaz'),
      _QueueTicket('D21', AppColors.warning, 'waiting', 16, 'Maria Keller'),
      _QueueTicket('A34', AppColors.primary, 'waiting', 6, 'Jonas Weber'),
      _QueueTicket('B13', AppColors.error, 'waiting', 10, 'Lina Becker'),
      _QueueTicket('C08', AppColors.success, 'waiting', 14, 'David Roth'),
      _QueueTicket('D22', AppColors.warning, 'called', 3, 'Sara Klein'),
    ];
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

class _QueueTicket {
  final String number;
  final Color color;
  final String status;
  final int waitMinutes;
  final String patientName;

  const _QueueTicket(
    this.number,
    this.color,
    this.status,
    this.waitMinutes,
    this.patientName,
  );
}
