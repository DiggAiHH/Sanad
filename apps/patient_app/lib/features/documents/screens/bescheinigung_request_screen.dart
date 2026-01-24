import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Screen zum Anfragen einer allgemeinen Bescheinigung.
/// DSGVO-konform: Nur notwendige Daten werden erhoben.
class BescheinigungRequestScreen extends ConsumerStatefulWidget {
  const BescheinigungRequestScreen({super.key});

  @override
  ConsumerState<BescheinigungRequestScreen> createState() =>
      _BescheinigungRequestScreenState();
}

class _BescheinigungRequestScreenState
    extends ConsumerState<BescheinigungRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  String _certificateType = 'fitness';
  String _priority = 'normal';
  String _deliveryMethod = 'pickup';
  bool _isSubmitting = false;
  bool _acceptedPrivacy = false;

  final _certificateTypes = [
    {'value': 'fitness', 'label': 'Sporttauglichkeit', 'icon': Icons.fitness_center},
    {'value': 'travel', 'label': 'Reisetauglichkeit', 'icon': Icons.flight},
    {'value': 'work', 'label': 'Arbeitsfähigkeit', 'icon': Icons.work},
    {'value': 'disability', 'label': 'Behindertenausweis', 'icon': Icons.accessible},
    {'value': 'vaccination', 'label': 'Impfbescheinigung', 'icon': Icons.vaccines},
    {'value': 'school', 'label': 'Schulbescheinigung', 'icon': Icons.school},
    {'value': 'driver', 'label': 'Fahreignung', 'icon': Icons.directions_car},
    {'value': 'other', 'label': 'Sonstige', 'icon': Icons.description},
  ];

  @override
  void dispose() {
    _purposeController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte akzeptieren Sie die Datenschutzhinweise.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // TODO: Connect to actual API
      // final service = ref.read(documentRequestServiceProvider);
      // await service.requestBescheinigung(
      //   certificateType: _certificateType,
      //   purpose: _purposeController.text.trim(),
      //   additionalInfo: _additionalInfoController.text.trim(),
      //   priority: _priority,
      //   deliveryMethod: _deliveryMethod,
      // );

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: Icon(Icons.check_circle, color: AppColors.success, size: 48),
            title: const Text('Anfrage gesendet'),
            content: const Text(
              'Ihre Bescheinigungsanfrage wurde erfolgreich übermittelt. '
              'Sie werden benachrichtigt, sobald diese bearbeitet wurde.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Senden: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bescheinigung anfragen'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ärztliche Bescheinigungen für verschiedene Zwecke. '
                        'Bitte beachten Sie, dass manche Bescheinigungen eine persönliche Untersuchung erfordern.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Certificate Type Selection
              Text(
                'Art der Bescheinigung *',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _certificateTypes.map((type) {
                  final isSelected = _certificateType == type['value'];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _certificateType = type['value'] as String);
                    },
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 48) / 2,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            type['icon'] as IconData,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              type['label'] as String,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Purpose
              Text(
                'Verwendungszweck *',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _purposeController,
                decoration: InputDecoration(
                  hintText: 'z.B. Vereinsanmeldung, Führerscheinantrag...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte geben Sie den Verwendungszweck an.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Additional Info
              Text(
                'Zusätzliche Angaben (optional)',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _additionalInfoController,
                decoration: InputDecoration(
                  hintText: 'Besondere Anforderungen oder Informationen...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Priority
              Text(
                'Dringlichkeit',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'low',
                    label: Text('Gering'),
                    icon: Icon(Icons.schedule),
                  ),
                  ButtonSegment(
                    value: 'normal',
                    label: Text('Normal'),
                    icon: Icon(Icons.check_circle_outline),
                  ),
                  ButtonSegment(
                    value: 'high',
                    label: Text('Eilig'),
                    icon: Icon(Icons.priority_high),
                  ),
                ],
                selected: {_priority},
                onSelectionChanged: (values) {
                  setState(() => _priority = values.first);
                },
              ),
              const SizedBox(height: 24),

              // Delivery Method
              Text(
                'Abholung/Zustellung',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SanadDropdown<String>(
                value: _deliveryMethod,
                hint: 'Abholung/Zustellung auswählen',
                items: const [
                  DropdownMenuItem(
                    value: 'pickup',
                    child: Text('Abholung in der Praxis'),
                  ),
                  DropdownMenuItem(
                    value: 'mail',
                    child: Text('Postzustellung'),
                  ),
                  DropdownMenuItem(
                    value: 'digital',
                    child: Text('Digital (wenn möglich)'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _deliveryMethod = value ?? 'pickup');
                },
              ),
              const SizedBox(height: 24),

              // Privacy notice and consent
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.privacy_tip, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Datenschutzhinweis',
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ihre Angaben werden gemäß DSGVO verarbeitet und '
                      'ausschließlich zur Bearbeitung Ihrer Anfrage verwendet. '
                      'Die Daten werden in Ihrer Patientenakte dokumentiert.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: _acceptedPrivacy,
                      onChanged: (value) {
                        setState(() => _acceptedPrivacy = value ?? false);
                      },
                      title: Text(
                        'Ich habe die Datenschutzhinweise gelesen und stimme der Verarbeitung meiner Daten zu.',
                        style: AppTextStyles.bodySmall,
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Note about examination
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hinweis: Für einige Bescheinigungen (z.B. Sporttauglichkeit, Fahreignung) '
                        'ist möglicherweise eine persönliche Untersuchung erforderlich.',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitRequest,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isSubmitting ? 'Wird gesendet...' : 'Anfrage absenden',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
