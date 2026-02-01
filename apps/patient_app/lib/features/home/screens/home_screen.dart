import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

import '../../../providers/last_ticket_provider.dart';

final publicQueueSummaryProvider =
    FutureProvider.autoDispose<PublicQueueSummary>((ref) async {
  final service = ref.watch(publicQueueSummaryServiceProvider);
  return service.getSummary();
});

/// Home screen for the patient app.
/// 
/// Provides quick access to ticket status check and practice information.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final summaryAsync = ref.watch(publicQueueSummaryProvider);
    final lastTicketNumber = ref.watch(lastTicketNumberProvider);
    final summary = summaryAsync.asData?.value;
    final openingHours = summary?.openingHours ?? 'Bitte erfragen';
    final averageWait = summary == null
        ? '—'
        : '${summary.averageWaitTimeMinutes} Min.';
    final nowServing = summary?.nowServingTicket ?? '—';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sanad'),
        actions: [
          ThemeModeMenuButton(
            mode: ref.watch(themeModeProvider),
            onSelected: (next) =>
                ref.read(themeModeProvider.notifier).setMode(next),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Logo/Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadius.extraLarge,
                      ),
                      child: const Icon(
                        Icons.local_hospital,
                        color: AppColors.textOnPrimary,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sanad',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Praxismanagement',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              // Welcome Message
              Container(
                padding: AppSpacing.cardPaddingLarge,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.35),
                  borderRadius: AppRadius.large,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.waving_hand,
                      color: colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Willkommen!',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hier können Sie Ihren Wartestatus einsehen und Informationen zur Praxis abrufen.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Quick Stats
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 520;
                  final cardWidth = isCompact
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 12) / 2;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _QuickStatCard(
                        icon: Icons.schedule,
                        title: 'Heute',
                        value: openingHours,
                        color: AppColors.primary,
                        width: cardWidth,
                      ),
                      _QuickStatCard(
                        icon: Icons.timer,
                        title: 'Ø Wartezeit',
                        value: averageWait,
                        color: AppColors.warning,
                        width: cardWidth,
                      ),
                      _QuickStatCard(
                        icon: Icons.campaign,
                        title: 'Jetzt dran',
                        value: nowServing,
                        color: AppColors.success,
                        width: cardWidth,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Main Actions
              _ActionCard(
                icon: Icons.confirmation_number,
                title: 'Ticket-Status',
                description: 'Geben Sie Ihre Ticketnummer ein, um Ihren aktuellen Wartestatus zu sehen.',
                buttonText: 'Status prüfen',
                onPressed: () => context.push('/ticket-entry'),
                isPrimary: true,
              ),
              if (lastTicketNumber != null && lastTicketNumber.isNotEmpty) ...[
                const SizedBox(height: 16),
                _ActionCard(
                  icon: Icons.history,
                  title: 'Letztes Ticket',
                  description:
                      'Zuletzt geprüft: $lastTicketNumber. Jetzt den Status erneut prüfen.',
                  buttonText: 'Letztes Ticket öffnen',
                  onPressed: () => context.push('/ticket/$lastTicketNumber'),
                ),
              ],
              const SizedBox(height: 16),
              
              // NEW: Document Request Action
              _ActionCard(
                icon: Icons.description,
                title: 'Dokumente anfordern',
                description: 'Rezepte, Überweisungen, AU-Bescheinigungen und andere Dokumente anfragen.',
                buttonText: 'Dokument anfragen',
                onPressed: () => context.push('/documents'),
              ),
              const SizedBox(height: 16),
              
              // NEW: Medication Plan Action
              _ActionCard(
                icon: Icons.medication,
                title: 'Medikationsplan',
                description: 'Ihre aktuellen Medikamente, Dosierungen und Hinweise.',
                buttonText: 'Plan anzeigen',
                onPressed: () => context.push('/medications'),
              ),
              const SizedBox(height: 16),
              
              // NEW: Consultation Action
              _ActionCard(
                icon: Icons.medical_services,
                title: 'Arzt kontaktieren',
                description: 'Chat, Video- oder Telefonsprechstunde mit Ihrem Arzt vereinbaren.',
                buttonText: 'Kontakt aufnehmen',
                onPressed: () => context.push('/consultation'),
              ),
              const SizedBox(height: 16),
              _ActionCard(
                icon: Icons.info_outline,
                title: 'Praxis-Information',
                description: 'Öffnungszeiten, Kontaktdaten und weitere Informationen.',
                buttonText: 'Mehr erfahren',
                onPressed: () => context.push('/info'),
              ),
              const SizedBox(height: 32),
              
              // Current Queue Overview
              Text(
                'Aktuelle Wartezeiten',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              summaryAsync.when(
                data: (summary) {
                  if (summary.queues.isEmpty) {
                    return Text(
                      'Derzeit sind keine Warteschlangen aktiv.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    );
                  }
                  return Column(
                    children: summary.queues.map((queue) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _WaitTimeCard(
                          category: queue.name,
                          code: queue.code,
                          waitTime: queue.averageWaitMinutes,
                          waitingCount: queue.waitingCount,
                          color: _colorFromHex(queue.color),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => Text(
                  'Wartezeiten konnten nicht geladen werden.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final double width;

  const _QuickStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AppRadius.medium,
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: AppRadius.small,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: AppSpacing.cardPaddingLarge,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.large,
        border: isPrimary 
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(color: colorScheme.outlineVariant),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPrimary 
                      ? AppColors.primary 
                      : AppColors.primaryLight.withOpacity(0.5),
                  borderRadius: AppRadius.medium,
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? AppColors.textOnPrimary : AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: isPrimary
                ? ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(buttonText),
                  )
                : OutlinedButton(
                    onPressed: onPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(buttonText),
                  ),
          ),
        ],
      ),
    );
  }
}

class _WaitTimeCard extends StatelessWidget {
  final String category;
  final String code;
  final int waitTime;
  final int waitingCount;
  final Color color;

  const _WaitTimeCard({
    required this.category,
    required this.code,
    required this.waitTime,
    required this.waitingCount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: AppRadius.small,
            ),
            child: Center(
              child: Text(
                code,
                style: AppTextStyles.titleLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$waitingCount Wartende',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '~$waitTime Min.',
                style: AppTextStyles.titleMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Wartezeit',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
