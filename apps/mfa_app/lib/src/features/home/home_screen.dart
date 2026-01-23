import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Keys for IoT device credentials in secure storage.
const _deviceIdKey = 'sanad_iot.device_id';
const _deviceSecretKey = 'sanad_iot.device_secret';

/// Provider that checks whether IoT device credentials are configured.
final iotDeviceConfiguredProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  final deviceId = await storage.getSecure(_deviceIdKey);
  final deviceSecret = await storage.getSecure(_deviceSecretKey);
  return deviceId != null && deviceId.isNotEmpty && deviceSecret != null && deviceSecret.isNotEmpty;
});

/// MFA Home screen with quick actions
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iotConfigAsync = ref.watch(iotDeviceConfiguredProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sanad Empfang'),
        actions: [
          // IoT device status chip
          iotConfigAsync.when(
            data: (configured) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Chip(
                avatar: Icon(
                  configured ? Icons.check_circle : Icons.warning_amber_rounded,
                  size: 18,
                  color: configured ? AppColors.success : AppColors.warning,
                ),
                label: Text(
                  configured ? 'NFC-Gerät OK' : 'NFC nicht konfiguriert',
                  style: AppTextStyles.bodySmall,
                ),
                backgroundColor: configured
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.warning.withOpacity(0.15),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          const QueueStatus(
            waitingCount: 8,
            inProgressCount: 2,
            compact: true,
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings/iot-device'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Quick stats
            LayoutBuilder(
              builder: (context, constraints) {
                final cards = [
                  _buildStatCard('Wartend', '8', AppColors.waiting),
                  _buildStatCard('Aufgerufen', '2', AppColors.called),
                  _buildStatCard('Ø Wartezeit', '12 Min', AppColors.info),
                ];
                if (constraints.maxWidth < 800) {
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
            ),
            const SizedBox(height: 16),
            iotConfigAsync.when(
              data: (configured) => configured
                  ? const SizedBox.shrink()
                  : _IotSetupCard(
                      onTap: () => context.push('/settings/iot-device'),
                    ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 32),
            // Main actions
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cards = [
                    _buildActionCard(
                      context,
                      title: 'Neuer Patient',
                      subtitle: 'Check-In & Laufnummer vergeben',
                      icon: Icons.person_add,
                      color: AppColors.primary,
                      onTap: () => context.push('/check-in'),
                    ),
                    _buildActionCard(
                      context,
                      title: 'Warteschlange',
                      subtitle: 'Aktuelle Warteschlange verwalten',
                      icon: Icons.queue,
                      color: AppColors.secondary,
                      onTap: () => context.push('/queue'),
                    ),
                  ];
                  if (constraints.maxWidth < 900) {
                    return Column(
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(height: 24),
                        Expanded(child: cards[1]),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 24),
                      Expanded(child: cards[1]),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cards = [
                    _buildActionCard(
                      context,
                      title: 'QR-Code Scan',
                      subtitle: 'Patient per QR-Code einchecken',
                      icon: Icons.qr_code_scanner,
                      color: AppColors.success,
                      onTap: () => context.push('/check-in/qr'),
                    ),
                    _buildActionCard(
                      context,
                      title: 'NFC Check-In',
                      subtitle: 'Patient per NFC-Karte einchecken',
                      icon: Icons.nfc,
                      color: AppColors.warning,
                      onTap: () => _showNfcDialog(context),
                    ),
                  ];
                  if (constraints.maxWidth < 900) {
                    return Column(
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(height: 24),
                        Expanded(child: cards[1]),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 24),
                      Expanded(child: cards[1]),
                    ],
                  );
                },
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

class _IotSetupCard extends StatelessWidget {
  final VoidCallback onTap;

  const _IotSetupCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.warning.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.nfc, color: AppColors.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'NFC-Gerät ist noch nicht eingerichtet. Jetzt konfigurieren?',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: onTap,
              child: const Text('Einrichten'),
            ),
          ],
        ),
      ),
    );
  }
}
