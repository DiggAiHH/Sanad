import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';
import 'router.dart';

/// Provider to track push initialization state.
final pushInitializedProvider = StateProvider<bool>((ref) => false);

/// MFA App for Ticket Issuance
class MfaApp extends ConsumerStatefulWidget {
  const MfaApp({super.key});

  @override
  ConsumerState<MfaApp> createState() => _MfaAppState();
}

class _MfaAppState extends ConsumerState<MfaApp> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      ref.read(pushInitializedProvider.notifier).state = true;
      return;
    }
    _initializePush();
  }

  Future<void> _initializePush() async {
    final pushService = ref.read(pushServiceProvider);

    await pushService.initializeAndRegister(
      deviceName: 'MFA App',
      appVersion: '1.0.0',
      onNotification: _handleForegroundNotification,
      onNotificationTapped: _handleNotificationTap,
    );

    // Subscribe to MFA-specific topics
    await pushService.subscribeToTopic('mfa_staff');

    ref.read(pushInitializedProvider.notifier).state = true;
  }

  void _handleForegroundNotification(PushNotificationPayload payload) {
    // Show in-app notification for new tickets
    if (payload.type == PushNotificationType.ticketCreated) {
      ModernSnackBar.show(
        context,
        message: '${payload.title}: ${payload.body}',
        type: SnackBarType.info,
        actionLabel: 'Anzeigen',
        onAction: () {
          // Navigate to queue screen
          ref.read(routerProvider).go('/queue');
        },
      );
    }
  }

  void _handleNotificationTap(PushNotificationPayload payload) {
    // Navigate based on notification type
    switch (payload.type) {
      case PushNotificationType.ticketCreated:
        ref.read(routerProvider).go('/queue');
        break;
      case PushNotificationType.ticketCalled:
        final ticketNumber = payload.ticketNumber;
        if (ticketNumber != null) {
          ref.read(routerProvider).go('/ticket/$ticketNumber');
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeModePreference = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Sanad Empfang',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeModePreference.themeMode,
      routerConfig: router,
    );
  }
}
