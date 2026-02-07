import 'package:flutter/material.dart';
import 'package:sanad_core/sanad_core.dart';

/// App bar action to change the current theme mode.
class ThemeModeMenuButton extends StatelessWidget {
  final ThemeModePreference mode;
  final ValueChanged<ThemeModePreference> onSelected;

  const ThemeModeMenuButton({
    super.key,
    required this.mode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ThemeModePreference>(
      tooltip: 'Design',
      icon: Icon(_iconFor(mode)),
      onSelected: onSelected,
      itemBuilder: (context) => [
        _menuItem(ThemeModePreference.light, 'Hell', Icons.light_mode),
        _menuItem(ThemeModePreference.dark, 'Dunkel', Icons.dark_mode),
        _menuItem(ThemeModePreference.system, 'System', Icons.brightness_auto),
      ],
    );
  }

  PopupMenuItem<ThemeModePreference> _menuItem(
    ThemeModePreference value,
    String label,
    IconData icon,
  ) {
    return PopupMenuItem<ThemeModePreference>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  IconData _iconFor(ThemeModePreference preference) {
    switch (preference) {
      case ThemeModePreference.light:
        return Icons.light_mode;
      case ThemeModePreference.dark:
        return Icons.dark_mode;
      case ThemeModePreference.system:
        return Icons.brightness_auto;
    }
  }
}
