import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sanad_core/sanad_core.dart';
import 'src/app.dart';

/// Sanad MFA App - Ticket issuance for medical assistants.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize storage
  final storage = StorageService();
  await storage.init();
  
  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
      ],
      child: const MfaApp(),
    ),
  );
}
