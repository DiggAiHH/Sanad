import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

import 'router.dart';

/// Provider to track push initialization state.
final pushInitializedProvider = StateProvider<bool>((ref) => false);

/// Root application widget for Sanad Patient App.
class PatientApp extends ConsumerStatefulWidget {
  const PatientApp({super.key});

  @override
  ConsumerState<PatientApp> createState() => _PatientAppState();
}

class _PatientAppState extends ConsumerState<PatientApp> {
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
      deviceName: 'Patient App',
      appVersion: '1.0.0',
      onNotification: _handleForegroundNotification,
      onNotificationTapped: _handleNotificationTap,
    );

    ref.read(pushInitializedProvider.notifier).state = true;
  }

  void _handleForegroundNotification(PushNotificationPayload payload) {
    // Show notification for ticket called or check-in success
    if (payload.type == PushNotificationType.ticketCalled) {
      _showTicketCalledDialog(payload);
    } else if (payload.type == PushNotificationType.checkInSuccess) {
      ModernSnackBar.show(
        context,
        message: payload.body,
        type: SnackBarType.success,
      );
    }
  }

  void _showTicketCalledDialog(PushNotificationPayload payload) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.green, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Text(payload.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              payload.body,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (payload.room != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    payload.room!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Verstanden'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(PushNotificationPayload payload) {
    // Navigate based on notification type
    switch (payload.type) {
      case PushNotificationType.ticketCalled:
      case PushNotificationType.checkInSuccess:
        final ticketNumber = payload.ticketNumber;
        if (ticketNumber != null) {
          router.go('/ticket/$ticketNumber');
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModePreference = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Sanad - Patienten-App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeModePreference.themeMode,
      routerConfig: router,
    );
  }
}
