import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Check-in screen for registering patients and issuing tickets
class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  String? _selectedCategory;
  final _searchController = TextEditingController();
  bool _isNewPatient = false;

  final _categories = [
    {'id': 'A', 'name': 'Allgemein', 'color': AppColors.primary},
    {'id': 'B', 'name': 'Blutabnahme', 'color': AppColors.error},
    {'id': 'C', 'name': 'Impfung', 'color': AppColors.success},
    {'id': 'D', 'name': 'Rezept abholen', 'color': AppColors.warning},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neuer Check-In'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient search
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Patient suchen', style: AppTextStyles.h5),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SearchInput(
                            hint: 'Name, Versichertennummer oder Telefon...',
                            onChanged: (value) {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/check-in/qr'),
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('QR Scan'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/check-in/nfc'),
                          icon: const Icon(Icons.nfc),
                          label: const Text('NFC'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search results would go here
                    if (!_isNewPatient) ...[
                      ListTile(
                        leading: const AppAvatar(name: 'Max Mustermann'),
                        title: const Text('Max Mustermann'),
                        subtitle: const Text('Geb. 15.03.1985 • Versichert: AOK'),
                        trailing: ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Auswählen'),
                        ),
                      ),
                      const Divider(),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => setState(() => _isNewPatient = true),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Neuen Patienten anlegen'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // New patient form
            if (_isNewPatient) ...[
              const SizedBox(height: 24),
              _buildNewPatientForm(),
            ],
            const SizedBox(height: 24),
            // Category selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Besuchsgrund wählen', style: AppTextStyles.h5),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat['id'];
                        final color = cat['color'] as Color;
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : color,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    cat['id'] as String,
                                    style: TextStyle(
                                      color: isSelected ? color : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(cat['name'] as String),
                            ],
                          ),
                          selected: isSelected,
                          selectedColor: color,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? cat['id'] as String : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Issue ticket button
            Center(
              child: SizedBox(
                width: 300,
                child: PrimaryButton(
                  label: 'Laufnummer vergeben',
                  icon: Icons.confirmation_number,
                  isFullWidth: true,
                  onPressed: _selectedCategory != null
                      ? () => _issueTicket(context)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewPatientForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Neuer Patient', style: AppTextStyles.h5),
                TextButton(
                  onPressed: () => setState(() => _isNewPatient = false),
                  child: const Text('Abbrechen'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: TextInput(label: 'Vorname', prefixIcon: Icons.person)),
                SizedBox(width: 16),
                Expanded(child: TextInput(label: 'Nachname', prefixIcon: Icons.person)),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: TextInput(label: 'Geburtsdatum', prefixIcon: Icons.cake)),
                SizedBox(width: 16),
                Expanded(child: TextInput(label: 'Telefon', prefixIcon: Icons.phone)),
              ],
            ),
            const SizedBox(height: 16),
            const TextInput(label: 'Versicherungsnummer', prefixIcon: Icons.credit_card),
          ],
        ),
      ),
    );
  }

  void _issueTicket(BuildContext context) {
    // Generate ticket number (in real app, this comes from backend)
    final ticketNumber = '$_selectedCategory${33}';
    context.push('/ticket/$ticketNumber');
  }
}
