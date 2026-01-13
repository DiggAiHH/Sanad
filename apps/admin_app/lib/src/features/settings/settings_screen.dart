import 'package:flutter/material.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Settings screen for admin
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Praxis-Informationen',
              children: [
                _buildSettingRow('Praxisname', 'Hausarztpraxis Dr. Müller', Icons.business),
                _buildSettingRow('Adresse', 'Hauptstraße 1, 12345 Berlin', Icons.location_on),
                _buildSettingRow('Telefon', '030 123456789', Icons.phone),
                _buildSettingRow('E-Mail', 'info@praxis-mueller.de', Icons.email),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Öffnungszeiten',
              children: [
                _buildTimeRow('Montag', '08:00 - 18:00'),
                _buildTimeRow('Dienstag', '08:00 - 18:00'),
                _buildTimeRow('Mittwoch', '08:00 - 13:00'),
                _buildTimeRow('Donnerstag', '08:00 - 18:00'),
                _buildTimeRow('Freitag', '08:00 - 13:00'),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Warteschlangen-Einstellungen',
              children: [
                _buildSwitchRow('QR-Code Check-In', true),
                _buildSwitchRow('NFC Check-In', true),
                _buildSwitchRow('Automatische Wartezeit-Berechnung', true),
                _buildSliderRow('Standard-Terminlänge', 15, 'Minuten'),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Patenten-App',
              children: [
                _buildSwitchRow('Aufklärungsvideos aktiviert', true),
                _buildSwitchRow('Push-Benachrichtigungen', true),
                _buildSwitchRow('Wartezeit-Anzeige', true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTextStyles.h5),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Bearbeiten'),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String day, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(day, style: AppTextStyles.bodyMedium),
          ),
          Text(time, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Switch(value: value, onChanged: (v) {}),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.bodyMedium),
              Text('${value.toInt()} $unit', style: AppTextStyles.labelMedium),
            ],
          ),
          Slider(
            value: value,
            min: 5,
            max: 60,
            divisions: 11,
            onChanged: (v) {},
          ),
        ],
      ),
    );
  }
}
