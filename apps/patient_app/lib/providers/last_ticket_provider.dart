import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanad_core/sanad_core.dart';

/// Provides the last stored ticket number for quick access.
final lastTicketNumberProvider = Provider<String?>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getString(AppConstants.keyLastTicketNumber);
});
