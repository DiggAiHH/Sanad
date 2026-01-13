import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// MFA Home screen with quick actions
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sanad Empfang'),
        actions: [
          const QueueStatus(
            waitingCount: 8,
            inProgressCount: 2,
            compact: true,
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Quick stats
            Row(
              children: [
                Expanded(child: _buildStatCard('Wartend', '8', AppColors.waiting)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Aufgerufen', '2', AppColors.called)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Ø Wartezeit', '12 Min', AppColors.info)),
              ],
            ),
            const SizedBox(height: 32),
            // Main actions
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      title: 'Neuer Patient',
                      subtitle: 'Check-In & Laufnummer vergeben',
                      icon: Icons.person_add,
                      color: AppColors.primary,
                      onTap: () => context.push('/check-in'),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      title: 'Warteschlange',
                      subtitle: 'Aktuelle Warteschlange verwalten',
                      icon: Icons.queue,
                      color: AppColors.secondary,
                      onTap: () => context.push('/queue'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      title: 'QR-Code Scan',
                      subtitle: 'Patient per QR-Code einchecken',
                      icon: Icons.qr_code_scanner,
                      color: AppColors.success,
                      onTap: () => context.push('/check-in/qr'),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      title: 'NFC Check-In',
                      subtitle: 'Patient per NFC-Karte einchecken',
                      icon: Icons.nfc,
                      color: AppColors.warning,
                      onTap: () => _showNfcDialog(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.h3.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 48, color: color),
              ),
              const SizedBox(height: 16),
              Text(title, style: AppTextStyles.h5, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNfcDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('NFC Check-In'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.nfc, size: 64, color: AppColors.warning),
            ),
            const SizedBox(height: 24),
            Text(
              'Bitte halten Sie die Karte\nan das Gerät',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
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
}
