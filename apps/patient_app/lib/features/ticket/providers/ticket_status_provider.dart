import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanad_core/sanad_core.dart';

/// Fetch public ticket status for a given display number.
final publicTicketStatusProvider =
    FutureProvider.family.autoDispose<PublicTicket, String>(
  (ref, ticketNumber) async {
    final service = ref.watch(publicTicketServiceProvider);
    return service.getTicketStatus(ticketNumber);
  },
);
