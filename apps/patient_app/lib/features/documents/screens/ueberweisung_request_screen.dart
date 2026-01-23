import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Screen für Überweisung-Anfrage.
class UeberweisungRequestScreen extends ConsumerStatefulWidget {
  const UeberweisungRequestScreen({super.key});

  @override
  ConsumerState<UeberweisungRequestScreen> createState() =>
      _UeberweisungRequestScreenState();
}

class _UeberweisungRequestScreenState
    extends ConsumerState<UeberweisungRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _doctorController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  String? _selectedSpecialty;
  DocumentRequestPriority _priority = DocumentRequestPriority.normal;
  DeliveryMethod _delivery = DeliveryMethod.pickup;

  final List<String> _specialties = [
    'Orthopädie',
    'Kardiologie',
    'Dermatologie',
    'HNO',
    'Augenheilkunde',
    'Neurologie',
    'Gynäkologie',
    'Urologie',
    'Gastroenterologie',
    'Pneumologie',
    'Radiologie',
    'Psychiatrie',
    'Chirurgie',
    'Anästhesie',
    'Onkologie',
    'Rheumatologie',
    'Endokrinologie',
    'Nephrologie',
    'Sonstige',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _doctorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Überweisung'),
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Specialty Selection
              _buildSectionTitle('Fachrichtung *'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSpecialty,
                decoration: _inputDecoration('Fachrichtung auswählen', Icons.local_hospital),
                items: _specialties
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedSpecialty = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte wählen Sie eine Fachrichtung';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Reason
              _buildSectionTitle('Grund der Überweisung *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                decoration: _inputDecoration(
                  'z.B. Knieschmerzen seit 3 Wochen',
                  Icons.description,
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie einen Grund an';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Preferred Doctor
              _buildSectionTitle('Wunsch-Arzt/Praxis (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _doctorController,
                decoration: _inputDecoration(
                  'Name oder Praxis',
                  Icons.person,
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
                  backgroundColor: AppColors.success,
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
                        'Überweisung anfordern',
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
      prefixIcon: Icon(icon, color: AppColors.success),
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
        borderSide: BorderSide(color: AppColors.success, width: 2),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children: [
        Expanded(
          child: _PriorityOption(
            label: 'Normal',
            isSelected: _priority == DocumentRequestPriority.normal,
            onTap: () =>
                setState(() => _priority = DocumentRequestPriority.normal),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PriorityOption(
            label: 'Dringend',
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
      await service.requestUeberweisung(
        specialty: _selectedSpecialty!,
        reason: _reasonController.text,
        preferredDoctor: _doctorController.text.isNotEmpty
            ? _doctorController.text
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        priority: _priority,
        delivery: _delivery,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Überweisungsanfrage erfolgreich gesendet'),
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

class _PriorityOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _PriorityOption({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final optionColor = color ?? AppColors.success;
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
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.titleMedium.copyWith(
              color: isSelected ? optionColor : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
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
              ? AppColors.success.withOpacity(0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.success : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.success : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color:
                    isSelected ? AppColors.success : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
