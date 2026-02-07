import 'package:flutter/material.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Settings screen for admin
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _qrCheckIn = true;
  bool _nfcCheckIn = true;
  bool _autoWait = true;
  double _defaultSlot = 15;
  bool _eduVideos = true;
  bool _pushNotifications = true;
  bool _showWaitTime = true;
  DateTime _lastUpdated = DateTime.now();

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
            _buildLastUpdated(context),
            const SizedBox(height: 16),
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
                SanadToggle(
                  label: 'QR-Code Check-In',
                  value: _qrCheckIn,
                  onChanged: (value) => _updateSetting(() => _qrCheckIn = value),
                ),
                SanadToggle(
                  label: 'NFC Check-In',
                  value: _nfcCheckIn,
                  onChanged: (value) => _updateSetting(() => _nfcCheckIn = value),
                ),
                SanadToggle(
                  label: 'Automatische Wartezeit-Berechnung',
                  value: _autoWait,
                  onChanged: (value) => _updateSetting(() => _autoWait = value),
                ),
                _buildSliderRow(
                  'Standard-Terminlänge',
                  _defaultSlot,
                  'Minuten',
                  (value) => _updateSetting(() => _defaultSlot = value),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Patienten-App',
              children: [
                SanadToggle(
                  label: 'Aufklärungsvideos aktiviert',
                  value: _eduVideos,
                  onChanged: (value) => _updateSetting(() => _eduVideos = value),
                ),
                SanadToggle(
                  label: 'Push-Benachrichtigungen',
                  value: _pushNotifications,
                  onChanged: (value) => _updateSetting(() => _pushNotifications = value),
                ),
                SanadToggle(
                  label: 'Wartezeit-Anzeige',
                  value: _showWaitTime,
                  onChanged: (value) => _updateSetting(() => _showWaitTime = value),
                ),
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

  Widget _buildSliderRow(
    String label,
    double value,
    String unit,
    ValueChanged<double> onChanged,
  ) {
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
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final timeOfDay = TimeOfDay.fromDateTime(_lastUpdated);
    final formatted = localizations.formatTimeOfDay(
      timeOfDay,
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Icon(Icons.update, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          'Zuletzt geändert: $formatted',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _updateSetting(VoidCallback update) {
    setState(() {
      update();
      _lastUpdated = DateTime.now();
    });
  }
}
