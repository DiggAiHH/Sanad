import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Admin dashboard with overview statistics
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
            tooltip: 'Aktualisieren',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Benachrichtigungen',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats cards
            _buildStatsRow(),
            const SizedBox(height: 24),
            // Charts row
            _buildChartsRow(context),
            const SizedBox(height: 24),
            // Recent activity
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Patienten Heute', '47', Icons.people, AppColors.primary)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Wartezeit Ø', '12 Min', Icons.schedule, AppColors.warning)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Aktive Mitarbeiter', '8', Icons.badge, AppColors.success)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Offene Aufgaben', '15', Icons.task_alt, AppColors.error)),
      ],
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Queue chart
        Expanded(
          flex: 2,
          child: Card(
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
          ),
        ),
        const SizedBox(width: 16),
        // Queue distribution
        Expanded(
          child: Card(
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
          ),
        ),
      ],
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
}
