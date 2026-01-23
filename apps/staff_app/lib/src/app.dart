import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';
import 'router.dart';

/// Staff/Doctor App for Chat and Tasks
class StaffApp extends ConsumerWidget {
  const StaffApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeModePreference = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Sanad Team',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeModePreference.themeMode,
      routerConfig: router,
    );
  }
}
