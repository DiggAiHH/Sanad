import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';
import 'router.dart';

/// Admin Dashboard App (God Mode)
class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeModePreference = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Sanad Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeModePreference.themeMode,
      routerConfig: router,
    );
  }
}
