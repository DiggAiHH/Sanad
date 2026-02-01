import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:core/core.dart';
import 'package:ui/ui.dart';

/// Online-Terminbuchung Screen
/// 
/// Ermöglicht Patienten, Termine direkt von zu Hause zu buchen:
/// - Termintyp auswählen
/// - Verfügbare Slots anzeigen
/// - Termin buchen mit Notiz
class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  int _currentStep = 0;
  String? _selectedType;
  DateTime _selectedDate = DateTime.now();
  String? _selectedSlot;
  final _notesController = TextEditingController();
  bool _isLoading = false;
  
  // Mock data - wird durch API ersetzt
  final List<AppointmentType> _types = [
    AppointmentType(id: 'acute', name: 'Akutsprechstunde', duration: 15, icon: Icons.warning_amber),
    AppointmentType(id: 'checkup', name: 'Vorsorge/Check-up', duration: 30, icon: Icons.health_and_safety),
    AppointmentType(id: 'vaccination', name: 'Impfung', duration: 15, icon: Icons.vaccines),
    AppointmentType(id: 'followup', name: 'Nachkontrolle', duration: 20, icon: Icons.replay),
    AppointmentType(id: 'lab_results', name: 'Laborbesprechung', duration: 15, icon: Icons.science),
    AppointmentType(id: 'prescription', name: 'Rezept/Überweisung', duration: 10, icon: Icons.description),
    AppointmentType(id: 'telemedicine', name: 'Videosprechstunde', duration: 20, icon: Icons.video_call),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appointmentBook),
        elevation: 0,
      ),
      body: SafeArea(
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          onStepTapped: (step) => setState(() => _currentStep = step),
          controlsBuilder: _buildControls,
          steps: [
            // Schritt 1: Termintyp
            Step(
              title: Text(l10n.appointmentSelectType),
              subtitle: _selectedType != null 
                  ? Text(_types.firstWhere((t) => t.id == _selectedType).name)
                  : null,
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildTypeSelection(),
            ),
            // Schritt 2: Datum & Uhrzeit
            Step(
              title: Text(l10n.appointmentSelectDateTime),
              subtitle: _selectedSlot != null 
                  ? Text('${DateFormat('dd.MM.yyyy').format(_selectedDate)} - $_selectedSlot')
                  : null,
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildDateTimeSelection(),
            ),
            // Schritt 3: Bestätigung
            Step(
              title: Text(l10n.appointmentConfirm),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: _buildConfirmation(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
    final l10n = context.l10n;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.appointmentTypeDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_types.length, (index) {
          final type = _types[index];
          final isSelected = _selectedType == type.id;
          
          return Semantics(
            label: '${type.name}, ${type.duration} ${l10n.minutesAbbrev}',
            selected: isSelected,
            child: Card(
              elevation: isSelected ? 4 : 1,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedType = type.id),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          type.icon,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            Text(
                              '~${type.duration} ${l10n.minutesAbbrev}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDateTimeSelection() {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    
    // Mock verfügbare Slots
    final availableSlots = [
      '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
      '11:00', '11:30', '14:00', '14:30', '15:00', '15:30',
      '16:00', '16:30', '17:00',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kalender
        Card(
          child: CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 90)),
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
                _selectedSlot = null; // Reset bei Datumswechsel
              });
            },
          ),
        ),
        const SizedBox(height: 24),
        
        // Verfügbare Zeiten
        Text(
          l10n.appointmentAvailableSlots,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableSlots.map((slot) {
            final isSelected = _selectedSlot == slot;
            return Semantics(
              label: '$slot Uhr',
              selected: isSelected,
              child: ChoiceChip(
                label: Text(slot),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedSlot = slot);
                  }
                },
                selectedColor: theme.colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: isSelected ? theme.colorScheme.primary : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // Info zur nächsten verfügbaren Zeit
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.appointmentNextAvailable,
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmation() {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    
    if (_selectedType == null || _selectedSlot == null) {
      return Text(l10n.appointmentSelectBoth);
    }
    
    final type = _types.firstWhere((t) => t.id == _selectedType);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Zusammenfassung
        Card(
          color: theme.colorScheme.surfaceVariant,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _SummaryRow(
                  icon: Icons.category,
                  label: l10n.appointmentType,
                  value: type.name,
                ),
                const Divider(),
                _SummaryRow(
                  icon: Icons.calendar_today,
                  label: l10n.appointmentDate,
                  value: DateFormat('EEEE, dd. MMMM yyyy', 'de').format(_selectedDate),
                ),
                const Divider(),
                _SummaryRow(
                  icon: Icons.access_time,
                  label: l10n.appointmentTime,
                  value: '$_selectedSlot Uhr',
                ),
                const Divider(),
                _SummaryRow(
                  icon: Icons.timelapse,
                  label: l10n.appointmentDuration,
                  value: '~${type.duration} ${l10n.minutesAbbrev}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Notiz-Feld
        Text(
          l10n.appointmentNotes,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: l10n.appointmentNotesHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        
        // Hinweise
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.appointmentImportantInfo,
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• ${l10n.appointmentBringInsuranceCard}\n'
                '• ${l10n.appointmentArrive10Min}\n'
                '• ${l10n.appointmentCancelPolicy}',
                style: TextStyle(color: Colors.orange[900]),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Anamnese-Hinweis
        Card(
          color: Colors.green[50],
          child: ListTile(
            leading: Icon(Icons.assignment, color: Colors.green[700]),
            title: Text(l10n.appointmentFillAnamnesis),
            subtitle: Text(l10n.appointmentAnamnesisHint),
            trailing: TextButton(
              onPressed: () {
                // Navigation zum Anamnese-Bogen
                // Navigator.pushNamed(context, '/anamnesis');
              },
              child: Text(l10n.buttonStart),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, ControlsDetails details) {
    final l10n = context.l10n;
    
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (_currentStep > 0)
            TextButton.icon(
              onPressed: details.onStepCancel,
              icon: const Icon(Icons.arrow_back),
              label: Text(l10n.buttonBack),
            ),
          const Spacer(),
          if (_currentStep < 2)
            ElevatedButton.icon(
              onPressed: _canContinue() ? details.onStepContinue : null,
              icon: const Icon(Icons.arrow_forward),
              label: Text(l10n.buttonNext),
            )
          else
            ElevatedButton.icon(
              onPressed: _canContinue() ? _submitBooking : null,
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(l10n.appointmentBookNow),
            ),
        ],
      ),
    );
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0:
        return _selectedType != null;
      case 1:
        return _selectedSlot != null;
      case 2:
        return _selectedType != null && _selectedSlot != null;
      default:
        return false;
    }
  }

  void _onStepContinue() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitBooking() async {
    final l10n = context.l10n;
    
    setState(() => _isLoading = true);
    
    try {
      // TODO: API-Call zum Backend
      await Future.delayed(const Duration(seconds: 2)); // Simulate
      
      if (mounted) {
        // Erfolg
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: Text(l10n.appointmentSuccess),
            content: Text(l10n.appointmentSuccessMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dialog
                  Navigator.of(context).pop(); // Screen
                },
                child: Text(l10n.buttonOk),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorBookingFailed),
            backgroundColor: Colors.red,
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

/// Zusammenfassungs-Zeile
class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

/// Termintyp-Modell
class AppointmentType {
  final String id;
  final String name;
  final int duration;
  final IconData icon;
  
  const AppointmentType({
    required this.id,
    required this.name,
    required this.duration,
    required this.icon,
  });
}
