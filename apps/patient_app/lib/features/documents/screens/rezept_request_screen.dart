import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Screen für Rezept-Anfrage.
class RezeptRequestScreen extends ConsumerStatefulWidget {
  const RezeptRequestScreen({super.key});

  @override
  ConsumerState<RezeptRequestScreen> createState() =>
      _RezeptRequestScreenState();
}

class _RezeptRequestScreenState extends ConsumerState<RezeptRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicationController = TextEditingController();
  final _dosageController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  DocumentRequestPriority _priority = DocumentRequestPriority.normal;
  DeliveryMethod _delivery = DeliveryMethod.pickup;

  @override
  void dispose() {
    _medicationController.dispose();
    _dosageController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezept anfordern'),
        backgroundColor: AppColors.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Medication Name
              _buildSectionTitle('Medikament *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _medicationController,
                decoration: _inputDecoration(
                  'Medikamentenname',
                  Icons.medication,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie den Medikamentennamen ein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Dosage
              _buildSectionTitle('Dosierung (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dosageController,
                decoration: _inputDecoration(
                  'z.B. 400mg, 2x täglich',
                  Icons.scale,
                ),
              ),
              const SizedBox(height: 20),

              // Quantity
              _buildSectionTitle('Menge (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                decoration: _inputDecoration(
                  'z.B. 2 Packungen',
                  Icons.inventory_2,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Priority
              _buildSectionTitle('Dringlichkeit'),
              const SizedBox(height: 8),
              _buildPrioritySelector(),
              const SizedBox(height: 20),

              // Delivery Method
              _buildSectionTitle('Abholung / Zustellung'),
              const SizedBox(height: 8),
              _buildDeliverySelector(),
              const SizedBox(height: 20),

              // Notes
              _buildSectionTitle('Anmerkungen (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: _inputDecoration(
                  'Zusätzliche Informationen',
                  Icons.note,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // DSGVO Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield, color: AppColors.info, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ihre Daten werden gemäß DSGVO geschützt und '
                        'nur für die Bearbeitung verwendet.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Rezept anfordern',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children: [
        _PriorityChip(
          label: 'Normal',
          icon: Icons.schedule,
          isSelected: _priority == DocumentRequestPriority.normal,
          onTap: () => setState(() => _priority = DocumentRequestPriority.normal),
        ),
        const SizedBox(width: 8),
        _PriorityChip(
          label: 'Dringend',
          icon: Icons.priority_high,
          isSelected: _priority == DocumentRequestPriority.urgent,
          color: AppColors.warning,
          onTap: () => setState(() => _priority = DocumentRequestPriority.urgent),
        ),
        const SizedBox(width: 8),
        _PriorityChip(
          label: 'Express',
          icon: Icons.bolt,
          isSelected: _priority == DocumentRequestPriority.express,
          color: AppColors.error,
          onTap: () => setState(() => _priority = DocumentRequestPriority.express),
        ),
      ],
    );
  }

  Widget _buildDeliverySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _DeliveryChip(
          label: 'Abholung',
          icon: Icons.storefront,
          isSelected: _delivery == DeliveryMethod.pickup,
          onTap: () => setState(() => _delivery = DeliveryMethod.pickup),
        ),
        _DeliveryChip(
          label: 'E-Mail',
          icon: Icons.email,
          isSelected: _delivery == DeliveryMethod.email,
          onTap: () => setState(() => _delivery = DeliveryMethod.email),
        ),
        _DeliveryChip(
          label: 'Post',
          icon: Icons.local_shipping,
          isSelected: _delivery == DeliveryMethod.post,
          onTap: () => setState(() => _delivery = DeliveryMethod.post),
        ),
        _DeliveryChip(
          label: 'ePA',
          icon: Icons.health_and_safety,
          isSelected: _delivery == DeliveryMethod.digitalHealth,
          onTap: () => setState(() => _delivery = DeliveryMethod.digitalHealth),
        ),
      ],
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(documentRequestServiceProvider);
      await service.requestRezept(
        medicationName: _medicationController.text,
        dosage: _dosageController.text.isNotEmpty ? _dosageController.text : null,
        quantity: _quantityController.text.isNotEmpty
            ? int.tryParse(_quantityController.text)
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        priority: _priority,
        delivery: _delivery,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Rezeptanfrage erfolgreich gesendet'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _PriorityChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chipColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withOpacity(0.15) : colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? chipColor : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? chipColor : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? chipColor : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeliveryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.15)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
