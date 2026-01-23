import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:patient_app/features/consultation/screens/consultations_screen.dart';
import 'package:patient_app/features/documents/screens/document_requests_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders consultation entry points', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ConsultationsScreen(),
        ),
      ),
    );

    expect(find.text('Arzt kontaktieren'), findsOneWidget);
    expect(find.text('Videosprechstunde'), findsOneWidget);
    expect(find.text('Telefonsprechstunde'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Rückruf anfordern'), findsOneWidget);
    expect(find.text('Aktive Gespräche'), findsOneWidget);
  });

  testWidgets('renders document request quick actions', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DocumentRequestsScreen(),
        ),
      ),
    );

    expect(find.text('Dokumente anfordern'), findsOneWidget);
    expect(find.text('Schnellanfrage'), findsOneWidget);
    expect(find.text('Rezept'), findsOneWidget);
    expect(find.text('AU-Bescheinigung'), findsOneWidget);
    expect(find.text('Überweisung'), findsOneWidget);
    expect(find.text('Bescheinigung'), findsOneWidget);
  });
}
