import 'package:go_router/go_router.dart';

import 'features/home/screens/home_screen.dart';
import 'features/ticket/screens/ticket_entry_screen.dart';
import 'features/ticket/screens/ticket_status_screen.dart';
import 'features/info/screens/info_screen.dart';

/// Application router configuration.
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/ticket-entry',
      builder: (context, state) => const TicketEntryScreen(),
    ),
    GoRoute(
      path: '/ticket/:ticketNumber',
      builder: (context, state) {
        final ticketNumber = state.pathParameters['ticketNumber'] ?? '';
        return TicketStatusScreen(ticketNumber: ticketNumber);
      },
    ),
    GoRoute(
      path: '/info',
      builder: (context, state) => const InfoScreen(),
    ),
  ],
);
