import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanad_core/sanad_core.dart';

import 'app.dart';

/// Sanad Patient App - Patienten-App für Wartezeit und Ticket-Status.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  final storage = StorageService();
  await storage.init();
  
  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
        themeModeProvider.overrideWith(
          (ref) => ThemeModeController(
            storage,
            storageKey: AppConstants.keyThemeModePatient,
          ),
        ),
      ],
      child: const PatientApp(),
    ),
  );
}
