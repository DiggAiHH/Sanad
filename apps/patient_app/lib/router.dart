import 'package:go_router/go_router.dart';

import 'features/home/screens/home_screen.dart';
import 'features/ticket/screens/ticket_entry_screen.dart';
import 'features/ticket/screens/ticket_status_screen.dart';
import 'features/info/screens/info_screen.dart';
import 'features/documents/documents.dart';
import 'features/consultation/consultation.dart';

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
      redirect: (context, state) {
        final ticketNumber = state.pathParameters['ticketNumber'] ?? '';
        final isValid = RegExp(r'^[A-Za-z]-?\d{1,4}$').hasMatch(ticketNumber);
        return isValid ? null : '/ticket-entry';
      },
      builder: (context, state) {
        final ticketNumber = state.pathParameters['ticketNumber'] ?? '';
        return TicketStatusScreen(ticketNumber: ticketNumber);
      },
    ),
    GoRoute(
      path: '/info',
      builder: (context, state) => const InfoScreen(),
    ),
    
    // Document Request Routes
    GoRoute(
      path: '/documents',
      builder: (context, state) => const DocumentRequestsScreen(),
    ),
    GoRoute(
      path: '/documents/rezept',
      builder: (context, state) => const RezeptRequestScreen(),
    ),
    GoRoute(
      path: '/documents/au',
      builder: (context, state) => const AURequestScreen(),
    ),
    GoRoute(
      path: '/documents/ueberweisung',
      builder: (context, state) => const UeberweisungRequestScreen(),
    ),
    GoRoute(
      path: '/documents/bescheinigung',
      builder: (context, state) => const BescheinigungRequestScreen(),
    ),
    
    // Consultation Routes
    GoRoute(
      path: '/consultation',
      builder: (context, state) => const ConsultationsScreen(),
    ),
    GoRoute(
      path: '/consultation/video',
      builder: (context, state) => const RequestVideoCallScreen(),
    ),
    GoRoute(
      path: '/consultation/voice',
      builder: (context, state) => const RequestCallbackScreen(),
    ),
    GoRoute(
      path: '/consultation/chat',
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: '/consultation/callback',
      builder: (context, state) => const RequestCallbackScreen(),
    ),
    GoRoute(
      path: '/consultation/video/active',
      builder: (context, state) => const VideoCallScreen(),
    ),
    GoRoute(
      path: '/consultation/voice/active',
      builder: (context, state) => const VoiceCallScreen(),
    ),
    GoRoute(
      path: '/consultation/chat/:id',
      builder: (context, state) {
        final consultationId = state.pathParameters['id'];
        return ChatScreen(consultationId: consultationId);
      },
    ),
  ],
);
