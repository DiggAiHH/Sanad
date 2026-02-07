import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

final medicationPlanProvider =
    FutureProvider.autoDispose<MedicationPlan>((ref) async {
  final service = ref.watch(medicationServiceProvider);
  return service.getMedicationPlan();
});

/// Screen for the patient's medication plan.
class MedicationPlanScreen extends ConsumerWidget {
  const MedicationPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(medicationPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medikationsplan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          ThemeModeMenuButton(
            mode: ref.watch(themeModeProvider),
            onSelected: (next) =>
                ref.read(themeModeProvider.notifier).setMode(next),
          ),
        ],
      ),
      body: planAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(error: error),
        data: (plan) {
          if (plan.medications.isEmpty) {
            return _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: plan.medications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final medication = plan.medications[index];
              return _MedicationCard(medication: medication);
            },
          );
        },
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final Medication medication;

  const _MedicationCard({required this.medication});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dosageText = medication.dosages.isEmpty
        ? 'Dosierung folgt'
        : medication.dosages
            .map((dose) => '${dose.amount} ${dose.unit} (${_timeLabel(dose.time)})')
            .join(', ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medication, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  medication.name,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _StatusBadge(status: medication.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${medication.activeIngredient} • ${medication.strength}',
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dosierung: $dosageText',
            style: AppTextStyles.bodyMedium,
          ),
          if (medication.instructions != null &&
              medication.instructions!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              medication.instructions!,
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _timeLabel(String value) {
    switch (value) {
      case 'morning':
        return 'morgens';
      case 'noon':
        return 'mittags';
      case 'evening':
        return 'abends';
      case 'night':
        return 'nachts';
      case 'as_needed':
        return 'bei Bedarf';
      default:
        return value;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final MedicationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case MedicationStatus.active:
        color = AppColors.success;
        label = 'Aktiv';
        break;
      case MedicationStatus.paused:
        color = AppColors.warning;
        label = 'Pausiert';
        break;
      case MedicationStatus.discontinued:
        color = AppColors.error;
        label = 'Abgesetzt';
        break;
      case MedicationStatus.completed:
        color = AppColors.completed;
        label = 'Beendet';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            'Kein Medikationsplan vorhanden',
            style: AppTextStyles.bodyLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Fehler beim Laden',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
