import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanad_core/sanad_core.dart';

import 'package:patient_app/features/ticket/providers/ticket_status_provider.dart';
import 'package:patient_app/features/ticket/screens/ticket_status_screen.dart';

class _TestConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  _TestConnectivityNotifier() : super(ConnectivityStatus.online);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows waiting status for ticket', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();

    final ticket = PublicTicket(
      queueId: 'queue-1',
      ticketNumber: 'A-001',
      status: TicketStatus.waiting,
      estimatedWaitMinutes: 10,
      calledAt: null,
      completedAt: null,
      createdAt: DateTime(2026, 1, 1, 8, 0),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
          connectivityProvider.overrideWith((ref) => _TestConnectivityNotifier()),
          publicTicketStatusProvider.overrideWith(
            (ref, ticketNumber) async => ticket,
          ),
        ],
        child: const MaterialApp(
          home: TicketStatusScreen(ticketNumber: 'A-001'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Ticket A-001'), findsOneWidget);
    expect(find.text('In Warteschlange'), findsOneWidget);
    expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
  });
}
