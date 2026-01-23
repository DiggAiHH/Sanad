import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Admin dashboard with overview statistics
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _lastUpdated = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Aktualisieren',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Benachrichtigungen',
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats cards
              _buildStatsRow(),
              const SizedBox(height: 8),
              _buildLastUpdated(context),
              const SizedBox(height: 24),
              // Charts row
              _buildChartsRow(context),
              const SizedBox(height: 24),
              // Recent activity
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final cards = [
      _buildStatCard('Patienten Heute', '47', Icons.people, AppColors.primary),
      _buildStatCard('Wartezeit Ø', '12 Min', Icons.schedule, AppColors.warning),
      _buildStatCard('Aktive Mitarbeiter', '8', Icons.badge, AppColors.success),
      _buildStatCard('Offene Aufgaben', '15', Icons.task_alt, AppColors.error),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: cards
                .map((card) => SizedBox(
                      width: (constraints.maxWidth - 16) / 2,
                      child: card,
                    ))
                .toList(),
          );
        }
        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i != cards.length - 1) const SizedBox(width: 16),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text(title, style: AppTextStyles.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsRow(BuildContext context) {
    final queueChart = Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patientenaufkommen', style: AppTextStyles.h5),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3),
                        FlSpot(1, 5),
                        FlSpot(2, 8),
                        FlSpot(3, 12),
                        FlSpot(4, 9),
                        FlSpot(5, 7),
                        FlSpot(6, 4),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final distributionChart = Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verteilung', style: AppTextStyles.h5),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 40,
                      title: 'A',
                      color: AppColors.primary,
                    ),
                    PieChartSectionData(
                      value: 30,
                      title: 'B',
                      color: AppColors.secondary,
                    ),
                    PieChartSectionData(
                      value: 20,
                      title: 'C',
                      color: AppColors.warning,
                    ),
                    PieChartSectionData(
                      value: 10,
                      title: 'D',
                      color: AppColors.success,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(
            children: [
              queueChart,
              const SizedBox(height: 16),
              distributionChart,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: queueChart),
            const SizedBox(width: 16),
            Expanded(child: distributionChart),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Letzte Aktivitäten', style: AppTextStyles.h5),
                TextButton(
                  onPressed: () {},
                  child: const Text('Alle anzeigen'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityItem('Neuer Patient registriert', 'Max Mustermann', 'vor 5 Min.', Icons.person_add),
            const Divider(),
            _buildActivityItem('Ticket aufgerufen', 'A33 - Raum 2', 'vor 8 Min.', Icons.campaign),
            const Divider(),
            _buildActivityItem('Aufgabe erledigt', 'Blutabnahme vorbereiten', 'vor 15 Min.', Icons.check_circle),
            const Divider(),
            _buildActivityItem('Mitarbeiter angemeldet', 'Dr. Schmidt', 'vor 20 Min.', Icons.login),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: Text(time, style: AppTextStyles.labelSmall),
      contentPadding: EdgeInsets.zero,
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
}
