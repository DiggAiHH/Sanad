import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

import '../providers/ticket_status_provider.dart';
import '../../../providers/last_ticket_provider.dart';

/// Screen displaying the status of a specific ticket.
class TicketStatusScreen extends ConsumerStatefulWidget {
  final String ticketNumber;

  const TicketStatusScreen({
    super.key,
    required this.ticketNumber,
  });

  @override
  ConsumerState<TicketStatusScreen> createState() => _TicketStatusScreenState();
}

class _TicketStatusScreenState extends ConsumerState<TicketStatusScreen>
    with WidgetsBindingObserver {
  Timer? _refreshTimer;
  DateTime _lastUpdated = DateTime.now();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _registerLastTicketListener();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopRefreshTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startRefreshTimer();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _stopRefreshTimer();
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshStatus();
    });
  }

  void _stopRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> _refreshStatus() async {
    final ticketNumber = _normalizedTicketNumber();
    if (ticketNumber.isEmpty) {
      return;
    }
    if (ref.read(connectivityProvider) == ConnectivityStatus.offline) {
      return;
    }
    await ref.refresh(publicTicketStatusProvider(ticketNumber).future);
    if (mounted) {
      setState(() => _lastUpdated = DateTime.now());
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    try {
      await _refreshStatus();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  String _normalizedTicketNumber() {
    return widget.ticketNumber.trim().toUpperCase();
  }

  String _formatTime(BuildContext context, DateTime time) {
    final localizations = MaterialLocalizations.of(context);
    final timeOfDay = TimeOfDay.fromDateTime(time);
    return localizations.formatTimeOfDay(
      timeOfDay,
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.called:
        return AppColors.success;
      case TicketStatus.inProgress:
        return AppColors.info;
      case TicketStatus.completed:
      case TicketStatus.cancelled:
      case TicketStatus.noShow:
        return AppColors.completed;
      default:
        return AppColors.warning;
    }
  }

  String _getStatusText(TicketStatus status) {
    switch (status) {
      case TicketStatus.called:
        return 'Sie werden aufgerufen!';
      case TicketStatus.inProgress:
        return 'In Behandlung';
      case TicketStatus.completed:
        return 'Abgeschlossen';
      case TicketStatus.cancelled:
        return 'Storniert';
      case TicketStatus.noShow:
        return 'Nicht erschienen';
      default:
        return 'In Warteschlange';
    }
  }

  String _getStatusShortText(TicketStatus status) {
    switch (status) {
      case TicketStatus.called:
        return 'Aufgerufen';
      case TicketStatus.inProgress:
        return 'Behandlung';
      case TicketStatus.completed:
        return 'Erledigt';
      case TicketStatus.cancelled:
        return 'Storniert';
      case TicketStatus.noShow:
        return 'Nicht da';
      default:
        return 'Wartend';
    }
  }

  IconData _getStatusIcon(TicketStatus status) {
    switch (status) {
      case TicketStatus.called:
        return Icons.notifications_active;
      case TicketStatus.inProgress:
        return Icons.medical_services;
      case TicketStatus.completed:
      case TicketStatus.cancelled:
      case TicketStatus.noShow:
        return Icons.check_circle;
      default:
        return Icons.hourglass_empty;
    }
  }

  String _mapError(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Keine Internetverbindung. Bitte pruefen Sie Ihr Netzwerk.';
      }
      if (status == 404) {
        return 'Ticket nicht gefunden. Bitte pruefen Sie die Nummer.';
      }
      if (status == 400) {
        return 'Ticketnummer ungueltig. Bitte erneut eingeben.';
      }
    }
    return 'Ticket konnte nicht geladen werden. Bitte versuchen Sie es erneut.';
  }

  void _registerLastTicketListener() {
    final ticketNumber = _normalizedTicketNumber();
    if (ticketNumber.isEmpty) {
      return;
    }
    ref.listen<AsyncValue<PublicTicket>>(
      publicTicketStatusProvider(ticketNumber),
      (previous, next) {
        next.whenData((_) {
          final storage = ref.read(storageServiceProvider);
          storage.setString(AppConstants.keyLastTicketNumber, ticketNumber);
          ref.invalidate(lastTicketNumberProvider);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final trimmedTicket = _normalizedTicketNumber();
    if (trimmedTicket.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          title: Text(
            'Ticket fehlt',
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        body: ScreenState(
          isEmpty: true,
          emptyTitle: 'Keine Ticketnummer gefunden',
          emptySubtitle: 'Bitte geben Sie Ihre Ticketnummer erneut ein.',
          emptyActionLabel: 'Ticket eingeben',
          onAction: () => context.go('/ticket-entry'),
          child: const SizedBox.shrink(),
        ),
      );
    }

    final ticketAsync = ref.watch(publicTicketStatusProvider(trimmedTicket));
    final isOffline =
        ref.watch(connectivityProvider) == ConnectivityStatus.offline;
    final errorMessage =
        ticketAsync.whenOrNull(error: (error, _) => _mapError(error));
    final isInitialLoading = ticketAsync.isLoading && !ticketAsync.hasValue;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'Ticket $trimmedTicket',
          style: AppTextStyles.titleLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isRefreshing ? Icons.sync : Icons.refresh,
              color: colorScheme.primary,
            ),
            onPressed: _isRefreshing ? null : _handleRefresh,
          ),
        ],
      ),
      body: SafeArea(
        child: ScreenState(
          isLoading: isInitialLoading,
          errorMessage: errorMessage,
          errorActionLabel: 'Erneut versuchen',
          onAction: () => ref.refresh(
            publicTicketStatusProvider(trimmedTicket).future,
          ),
          child: ticketAsync.maybeWhen(
            data: (ticket) => _TicketStatusContent(
              ticket: ticket,
              ticketNumber: trimmedTicket,
              lastUpdated: _lastUpdated,
              isRefreshing: _isRefreshing,
              onRefresh: _handleRefresh,
              formatTime: _formatTime,
              getStatusColor: _getStatusColor,
              getStatusText: _getStatusText,
              getStatusShortText: _getStatusShortText,
              getStatusIcon: _getStatusIcon,
              isOffline: isOffline,
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _TicketStatusContent extends StatelessWidget {
  final PublicTicket ticket;
  final String ticketNumber;
  final DateTime lastUpdated;
  final bool isRefreshing;
  final Future<void> Function() onRefresh;
  final String Function(BuildContext, DateTime) formatTime;
  final Color Function(TicketStatus) getStatusColor;
  final String Function(TicketStatus) getStatusText;
  final String Function(TicketStatus) getStatusShortText;
  final IconData Function(TicketStatus) getStatusIcon;
  final bool isOffline;

  const _TicketStatusContent({
    required this.ticket,
    required this.ticketNumber,
    required this.lastUpdated,
    required this.isRefreshing,
    required this.onRefresh,
    required this.formatTime,
    required this.getStatusColor,
    required this.getStatusText,
    required this.getStatusShortText,
    required this.getStatusIcon,
    required this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCalled = ticket.status == TicketStatus.called;
    final statusColor = getStatusColor(ticket.status);
    final estimatedCallTime = DateTime.now().add(
      Duration(minutes: ticket.estimatedWaitMinutes),
    );

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (isOffline) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Offline-Modus: Status kann veraltet sein.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (isCalled) ...[
              _CalledStatusCard(ticketNumber: ticketNumber),
            ] else ...[
              _WaitingStatusCard(
                ticketNumber: ticketNumber,
                statusColor: statusColor,
                statusText: getStatusText(ticket.status),
                statusShortText: getStatusShortText(ticket.status),
                statusIcon: getStatusIcon(ticket.status),
                estimatedWaitMinutes: ticket.estimatedWaitMinutes,
                createdAtTime: formatTime(context, ticket.createdAt),
                estimatedCallTime: formatTime(context, estimatedCallTime),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isRefreshing ? Icons.sync : Icons.update,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Letzte Aktualisierung: ${formatTime(context, lastUpdated)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Ihr Ticket-QR-Code',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  QrImageView(
                    data: 'sanad://ticket/$ticketNumber',
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ticketNumber,
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _InfoCard(
              icon: Icons.access_time,
              title: 'Auto-Aktualisierung',
              description:
                  'Diese Seite wird automatisch alle 30 Sekunden aktualisiert.',
            ),
            const SizedBox(height: 12),
            const _InfoCard(
              icon: Icons.volume_up,
              title: 'Aufruf',
              description:
                  'Achten Sie auf die Anzeige im Wartebereich, wenn Ihre Nummer aufgerufen wird.',
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => context.go('/'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    isCalled ? AppColors.success : AppColors.primary,
                side: BorderSide(
                  color: isCalled ? AppColors.success : AppColors.primary,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.home),
              label: const Text('Zur Startseite'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalledStatusCard extends StatelessWidget {
  final String ticketNumber;

  const _CalledStatusCard({required this.ticketNumber});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sie werden aufgerufen!',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bitte begeben Sie sich jetzt zum Behandlungszimmer.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              ticketNumber,
              style: AppTextStyles.displaySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
                letterSpacing: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaitingStatusCard extends StatelessWidget {
  final String ticketNumber;
  final Color statusColor;
  final String statusText;
  final String statusShortText;
  final IconData statusIcon;
  final int estimatedWaitMinutes;
  final String createdAtTime;
  final String estimatedCallTime;

  const _WaitingStatusCard({
    required this.ticketNumber,
    required this.statusColor,
    required this.statusText,
    required this.statusShortText,
    required this.statusIcon,
    required this.estimatedWaitMinutes,
    required this.createdAtTime,
    required this.estimatedCallTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            ticketNumber,
            style: AppTextStyles.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  value: '~$estimatedWaitMinutes',
                  label: 'Wartezeit (Min.)',
                  color: AppColors.warning,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppColors.border,
              ),
              Expanded(
                child: _StatItem(
                  value: statusShortText,
                  label: 'Status',
                  color: statusColor,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppColors.border,
              ),
              Expanded(
                child: _StatItem(
                  value: createdAtTime,
                  label: 'Ausgabe',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Voraussichtlich: $estimatedCallTime',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
