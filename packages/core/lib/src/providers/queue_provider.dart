import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ticket.dart';
import '../models/queue.dart';
import '../services/queue_service.dart';
import 'core_providers.dart';

/// Current practice ID provider (override per app)
final currentPracticeIdProvider = StateProvider<String>((ref) {
  return ''; // Set by app at runtime
});

/// Queue state provider
final queueStateProvider = FutureProvider.autoDispose<QueueState>((ref) async {
  final queueService = ref.watch(queueServiceProvider);
  final practiceId = ref.watch(currentPracticeIdProvider);
  if (practiceId.isEmpty) {
    throw StateError('Practice ID not set');
  }
  return queueService.getQueueState(practiceId);
});

/// Queue categories provider
final queueCategoriesProvider =
    FutureProvider.autoDispose<List<QueueCategory>>((ref) async {
  final queueService = ref.watch(queueServiceProvider);
  final practiceId = ref.watch(currentPracticeIdProvider);
  return queueService.getCategories(practiceId);
});

/// Active tickets provider
final activeTicketsProvider = Provider<List<Ticket>>((ref) {
  final queueState = ref.watch(queueStateProvider);
  return queueState.maybeWhen(
    data: (state) => state.activeTickets,
    orElse: () => [],
  );
});

/// Waiting tickets count
final waitingCountProvider = Provider<int>((ref) {
  final tickets = ref.watch(activeTicketsProvider);
  return tickets.where((t) => t.status == TicketStatus.waiting).length;
});

/// Patient's current ticket provider (for patient app)
final patientTicketProvider = FutureProvider.family
    .autoDispose<Ticket?, String>((ref, patientId) async {
  final queueService = ref.watch(queueServiceProvider);
  final practiceId = ref.watch(currentPracticeIdProvider);
  return queueService.getPatientActiveTicket(
    practiceId: practiceId,
    patientId: patientId,
  );
});

/// Ticket notifier for issuing and managing tickets
class TicketNotifier extends StateNotifier<AsyncValue<Ticket?>> {
  final QueueService _queueService;
  final String _practiceId;

  TicketNotifier(this._queueService, this._practiceId)
      : super(const AsyncValue.data(null));

  Future<Ticket> issueTicket({
    required String patientId,
    required String categoryId,
    String? visitReason,
  }) async {
    state = const AsyncValue.loading();
    try {
      final ticket = await _queueService.issueTicket(
        practiceId: _practiceId,
        patientId: patientId,
        categoryId: categoryId,
        visitReason: visitReason,
      );
      state = AsyncValue.data(ticket);
      return ticket;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Ticket?> callNext({
    String? categoryId,
    String? staffId,
    String? roomNumber,
  }) async {
    state = const AsyncValue.loading();
    try {
      final ticket = await _queueService.callNextTicket(
        practiceId: _practiceId,
        categoryId: categoryId,
        staffId: staffId,
        roomNumber: roomNumber,
      );
      state = AsyncValue.data(ticket);
      return ticket;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateStatus({
    required String ticketId,
    required TicketStatus status,
    String? notes,
  }) async {
    try {
      final ticket = await _queueService.updateTicketStatus(
        practiceId: _practiceId,
        ticketId: ticketId,
        status: status,
        notes: notes,
      );
      state = AsyncValue.data(ticket);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Ticket notifier provider
final ticketNotifierProvider =
    StateNotifierProvider<TicketNotifier, AsyncValue<Ticket?>>((ref) {
  final queueService = ref.watch(queueServiceProvider);
  final practiceId = ref.watch(currentPracticeIdProvider);
  return TicketNotifier(queueService, practiceId);
});
