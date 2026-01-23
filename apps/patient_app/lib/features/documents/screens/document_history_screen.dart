import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Screen showing full document request history.
class DocumentHistoryScreen extends ConsumerWidget {
  const DocumentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(myDocumentRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dokumentenverlauf'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          ThemeModeMenuButton(
            mode: ref.watch(themeModeProvider),
            onSelected: (next) =>
                ref.read(themeModeProvider.notifier).setMode(next),
          ),
        ],
      ),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(error: error),
        data: (requests) {
          if (requests.isEmpty) {
            return _EmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final request = requests[index];
              return _HistoryItem(request: request);
            },
          );
        },
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final DocumentRequest request;

  const _HistoryItem({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _StatusIndicator(status: request.status),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_typeLabel(request.documentType)} • ${_formatDate(request.createdAt)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _StatusBadge(status: request.status),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Heute';
    if (diff.inDays == 1) return 'Gestern';
    return '${date.day}.${date.month}.${date.year}';
  }

  String _typeLabel(DocumentType type) {
    switch (type) {
      case DocumentType.rezept:
        return 'Rezept';
      case DocumentType.ueberweisung:
        return 'Überweisung';
      case DocumentType.auBescheinigung:
        return 'AU';
      case DocumentType.bescheinigung:
        return 'Bescheinigung';
      case DocumentType.befund:
        return 'Befund';
      case DocumentType.attest:
        return 'Attest';
      case DocumentType.sonstige:
        return 'Sonstige';
    }
  }
}

class _StatusIndicator extends StatelessWidget {
  final DocumentRequestStatus status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case DocumentRequestStatus.pending:
        color = AppColors.warning;
        icon = Icons.hourglass_empty;
        break;
      case DocumentRequestStatus.inReview:
        color = AppColors.info;
        icon = Icons.visibility;
        break;
      case DocumentRequestStatus.approved:
      case DocumentRequestStatus.ready:
        color = AppColors.success;
        icon = Icons.check_circle;
        break;
      case DocumentRequestStatus.delivered:
        color = AppColors.textSecondary;
        icon = Icons.done_all;
        break;
      case DocumentRequestStatus.rejected:
      case DocumentRequestStatus.cancelled:
        color = AppColors.error;
        icon = Icons.cancel;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DocumentRequestStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case DocumentRequestStatus.pending:
        color = AppColors.warning;
        label = 'Ausstehend';
        break;
      case DocumentRequestStatus.inReview:
        color = AppColors.info;
        label = 'In Prüfung';
        break;
      case DocumentRequestStatus.approved:
      case DocumentRequestStatus.ready:
        color = AppColors.success;
        label = 'Bereit';
        break;
      case DocumentRequestStatus.delivered:
        color = AppColors.textSecondary;
        label = 'Abgeholt';
        break;
      case DocumentRequestStatus.rejected:
        color = AppColors.error;
        label = 'Abgelehnt';
        break;
      case DocumentRequestStatus.cancelled:
        color = AppColors.error;
        label = 'Storniert';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Noch keine Anfragen',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Fehler beim Laden',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
