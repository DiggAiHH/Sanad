import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Screen für AU-Bescheinigung-Anfrage.
class AURequestScreen extends ConsumerStatefulWidget {
  const AURequestScreen({super.key});

  @override
  ConsumerState<AURequestScreen> createState() => _AURequestScreenState();
}

class _AURequestScreenState extends ConsumerState<AURequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  DocumentRequestPriority _priority = DocumentRequestPriority.normal;
  DeliveryMethod _delivery = DeliveryMethod.pickup;

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AU-Bescheinigung'),
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Eine AU-Bescheinigung kann nur nach vorheriger '
                        'Untersuchung oder Videosprechstunde ausgestellt werden.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.warning.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Start Date
              _buildSectionTitle('Beginn der Arbeitsunfähigkeit *'),
              const SizedBox(height: 8),
              _DatePickerField(
                date: _startDate,
                onChanged: (date) => setState(() => _startDate = date),
                firstDate: DateTime.now().subtract(const Duration(days: 7)),
                lastDate: DateTime.now().add(const Duration(days: 1)),
              ),
              const SizedBox(height: 20),

              // End Date (optional)
              _buildSectionTitle('Voraussichtliches Ende (optional)'),
              const SizedBox(height: 8),
              _DatePickerField(
                date: _endDate,
                onChanged: (date) => setState(() => _endDate = date),
                firstDate: _startDate,
                lastDate: _startDate.add(const Duration(days: 42)),
                hint: 'Datum auswählen',
              ),
              const SizedBox(height: 20),

              // Reason
              _buildSectionTitle('Grund (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                decoration: _inputDecoration(
                  'z.B. Erkältung, Rückenschmerzen',
                  Icons.medical_services,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Der genaue Grund wird nicht auf der AU angegeben.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),

              // Priority
              _buildSectionTitle('Dringlichkeit'),
              const SizedBox(height: 8),
              _buildPrioritySelector(),
              const SizedBox(height: 20),

              // Delivery
              _buildSectionTitle('Zustellung'),
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

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
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
                        'AU-Bescheinigung anfordern',
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
        color: AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.warning),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.warning, width: 2),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children: [
        Expanded(
          child: _PriorityOption(
            label: 'Normal',
            subtitle: '2-3 Tage',
            isSelected: _priority == DocumentRequestPriority.normal,
            onTap: () =>
                setState(() => _priority = DocumentRequestPriority.normal),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PriorityOption(
            label: 'Dringend',
            subtitle: '1 Tag',
            isSelected: _priority == DocumentRequestPriority.urgent,
            color: AppColors.warning,
            onTap: () =>
                setState(() => _priority = DocumentRequestPriority.urgent),
          ),
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
      ],
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(documentRequestServiceProvider);
      await service.requestAU(
        startDate: _startDate,
        endDate: _endDate,
        reason:
            _reasonController.text.isNotEmpty ? _reasonController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        priority: _priority,
        delivery: _delivery,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('AU-Anfrage erfolgreich gesendet'),
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

class _DatePickerField extends StatelessWidget {
  final DateTime? date;
  final ValueChanged<DateTime> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? hint;

  const _DatePickerField({
    required this.date,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: firstDate,
          lastDate: lastDate,
          locale: const Locale('de', 'DE'),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.warning),
            const SizedBox(width: 12),
            Text(
              date != null
                  ? '${date!.day}.${date!.month}.${date!.year}'
                  : hint ?? 'Datum auswählen',
              style: AppTextStyles.bodyLarge.copyWith(
                color: date != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _PriorityOption({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final optionColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? optionColor.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? optionColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.titleMedium.copyWith(
                color: isSelected ? optionColor : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? optionColor : AppColors.textSecondary,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.warning.withOpacity(0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.warning : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.warning : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color:
                    isSelected ? AppColors.warning : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
