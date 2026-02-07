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
  String _searchQuery = '';
  bool _isNewPatient = false;

  final _categories = [
    {'id': 'A', 'name': 'Allgemein', 'color': AppColors.primary},
    {'id': 'B', 'name': 'Blutabnahme', 'color': AppColors.error},
    {'id': 'C', 'name': 'Impfung', 'color': AppColors.success},
    {'id': 'D', 'name': 'Rezept abholen', 'color': AppColors.warning},
  ];

  final _patients = [
    {
      'name': 'Max Mustermann',
      'dob': '15.03.1985',
      'insurance': 'AOK',
    },
    {
      'name': 'Lea Hoffmann',
      'dob': '22.08.1992',
      'insurance': 'TK',
    },
    {
      'name': 'Ahmet Yilmaz',
      'dob': '03.11.1978',
      'insurance': 'Barmer',
    },
  ];

  @override
  void dispose() {
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final searchField = SearchInput(
                          hint: 'Name, Versichertennummer oder Telefon...',
                          onChanged: (value) {
                            setState(() => _searchQuery = value.trim());
                          },
                          onClear: () => setState(() => _searchQuery = ''),
                        );
                        final qrButton = ElevatedButton.icon(
                          onPressed: () => context.push('/check-in/qr'),
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('QR Scan'),
                        );
                        final nfcButton = ElevatedButton.icon(
                          onPressed: () => context.push('/check-in/nfc'),
                          icon: const Icon(Icons.nfc),
                          label: const Text('NFC'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                          ),
                        );
                        if (constraints.maxWidth < 720) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              searchField,
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: qrButton),
                                  const SizedBox(width: 8),
                                  Expanded(child: nfcButton),
                                ],
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: searchField),
                            const SizedBox(width: 16),
                            qrButton,
                            const SizedBox(width: 8),
                            nfcButton,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Search results would go here
                    if (!_isNewPatient) ..._buildSearchResults(),
                  ],
                ),
              ),
            ),
            // New patient form
            if (_isNewPatient) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => setState(() => _isNewPatient = false),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Zurück zur Suche'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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

  List<Widget> _buildSearchResults() {
    final filtered = _patients.where((patient) {
      if (_searchQuery.isEmpty) return true;
      final name = (patient['name'] as String).toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    if (_searchQuery.isNotEmpty && filtered.isEmpty) {
      return [
        const SizedBox(height: 8),
        EmptyStateWidget.noData(
          title: 'Keine Treffer',
          subtitle: 'Für die Suche wurden keine Patienten gefunden.',
          actionLabel: 'Neuen Patienten anlegen',
          onAction: () => setState(() => _isNewPatient = true),
        ),
      ];
    }

    return [
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          'Treffer: ${filtered.length}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      const SizedBox(height: 8),
      ...filtered.map(
        (patient) => ListTile(
          leading: AppAvatar(name: patient['name'] as String),
          title: Text(patient['name'] as String),
          subtitle: Text(
            'Geb. ${patient['dob']} • Versichert: ${patient['insurance']}',
          ),
          trailing: ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Auswählen'),
          ),
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
    ];
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
