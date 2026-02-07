import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/home/home_screen.dart';
import 'features/check_in/check_in_screen.dart';
import 'features/check_in/nfc_check_in_screen.dart';
import 'features/check_in/qr_scanner_screen.dart';
import 'features/queue/queue_screen.dart';
import 'features/ticket/ticket_issued_screen.dart';
import 'features/settings/iot_device_credentials_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/check-in',
        builder: (context, state) => const CheckInScreen(),
      ),
      GoRoute(
        path: '/check-in/nfc',
        builder: (context, state) => const NfcCheckInScreen(),
      ),
      GoRoute(
        path: '/check-in/qr',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/queue',
        builder: (context, state) => const QueueScreen(),
      ),
      GoRoute(
        path: '/ticket/:ticketNumber',
        redirect: (context, state) {
          final ticketNumber = state.pathParameters['ticketNumber'] ?? '';
          final isValid = RegExp(r'^[A-Za-z]-?\d{1,4}$').hasMatch(ticketNumber);
          return isValid ? null : '/check-in';
        },
        builder: (context, state) {
          final ticketNumber = state.pathParameters['ticketNumber']!;
          final extraMap = state.extra as Map<String, dynamic>?;
          return TicketIssuedScreen(
            ticketNumber: ticketNumber,
            extra: TicketExtra.fromMap(extraMap),
          );
        },
      ),
      GoRoute(
        path: '/settings/iot-device',
        builder: (context, state) => const IotDeviceCredentialsScreen(),
      ),
    ],
  );
});
