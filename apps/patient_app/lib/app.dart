import 'package:flutter/material.dart';
import 'package:sanad_ui/sanad_ui.dart';

import 'router.dart';

/// Root application widget for Sanad Patient App.
class PatientApp extends StatelessWidget {
  const PatientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sanad - Patienten-App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
