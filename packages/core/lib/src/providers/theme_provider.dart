import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import 'core_providers.dart';

/// Theme preference for the app.
enum ThemeModePreference {
  light,
  dark,
  system,
}

extension ThemeModePreferenceX on ThemeModePreference {
  ThemeMode get themeMode {
    switch (this) {
      case ThemeModePreference.light:
        return ThemeMode.light;
      case ThemeModePreference.dark:
        return ThemeMode.dark;
      case ThemeModePreference.system:
        return ThemeMode.system;
    }
  }

  String get storageValue {
    switch (this) {
      case ThemeModePreference.light:
        return 'light';
      case ThemeModePreference.dark:
        return 'dark';
      case ThemeModePreference.system:
        return 'system';
    }
  }

  static ThemeModePreference fromStorage(String? value) {
    switch (value) {
      case 'light':
        return ThemeModePreference.light;
      case 'dark':
        return ThemeModePreference.dark;
      case 'system':
        return ThemeModePreference.system;
      default:
        return ThemeModePreference.dark;
    }
  }
}

/// Persists and exposes theme preference across apps.
class ThemeModeController extends StateNotifier<ThemeModePreference> {
  ThemeModeController(this._storage, {String? storageKey})
      : _storageKey = storageKey ?? AppConstants.keyThemeMode,
        super(ThemeModePreference.dark) {
    _loadPreference();
  }

  final StorageService _storage;
  final String _storageKey;

  Future<void> _loadPreference() async {
    final stored = _storage.getString(_storageKey);
    final resolved = ThemeModePreferenceX.fromStorage(stored);
    state = resolved;
    if (stored == null) {
      await _storage.setString(_storageKey, resolved.storageValue);
    }
  }

  Future<void> setMode(ThemeModePreference mode) async {
    state = mode;
    await _storage.setString(_storageKey, mode.storageValue);
  }

  Future<void> toggleLightDark() async {
    final next =
        state == ThemeModePreference.dark ? ThemeModePreference.light : ThemeModePreference.dark;
    await setMode(next);
  }
}

/// Provider for theme preference.
final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeModePreference>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeModeController(storage);
});
