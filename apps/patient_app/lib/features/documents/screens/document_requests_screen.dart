import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Screen für Dokumentenanfragen (Rezept, AU, Überweisung).
///
/// Patienten können hier schnell und einfach Dokumente anfordern.
class DocumentRequestsScreen extends ConsumerStatefulWidget {
  const DocumentRequestsScreen({super.key});

  @override
  ConsumerState<DocumentRequestsScreen> createState() =>
      _DocumentRequestsScreenState();
}

class _DocumentRequestsScreenState
    extends ConsumerState<DocumentRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final requestsAsync = ref.watch(myDocumentRequestsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dokumente anfordern'),
        backgroundColor: AppColors.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          ThemeModeMenuButton(
            mode: ref.watch(themeModeProvider),
            onSelected: (next) =>
                ref.read(themeModeProvider.notifier).setMode(next),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Wählen Sie das gewünschte Dokument aus. '
                      'Sie werden benachrichtigt, wenn es abholbereit ist.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions Grid
            Text(
              'Schnellanfrage',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _DocumentTypeCard(
                  icon: Icons.medication,
                  title: 'Rezept',
                  subtitle: 'Folgerezept anfordern',
                  color: AppColors.primary,
                  onTap: () => context.push('/documents/rezept'),
                ),
                _DocumentTypeCard(
                  icon: Icons.medical_information,
                  title: 'AU-Bescheinigung',
                  subtitle: 'Krankschreibung',
                  color: AppColors.warning,
                  onTap: () => context.push('/documents/au'),
                ),
                _DocumentTypeCard(
                  icon: Icons.send,
                  title: 'Überweisung',
                  subtitle: 'An Facharzt',
                  color: AppColors.success,
                  onTap: () => context.push('/documents/ueberweisung'),
                ),
                _DocumentTypeCard(
                  icon: Icons.description,
                  title: 'Bescheinigung',
                  subtitle: 'Sonstige Dokumente',
                  color: AppColors.secondary,
                  onTap: () => context.push('/documents/bescheinigung'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // My Requests Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meine Anfragen',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/documents/history'),
                  child: const Text('Alle anzeigen'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Recent requests
            requestsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorState(error),
              data: (requests) => _buildRecentRequests(requests),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRequests(List<DocumentRequest> requests) {
    if (requests.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Noch keine Anfragen',
              style: AppTextStyles.bodyLarge.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final recentRequests = requests.take(3).toList();
    return Column(
      children: recentRequests
          .map((req) => _RequestListItem(request: req))
          .toList(),
    );
  }

  Widget _buildErrorState(Object error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
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
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DocumentTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DocumentTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestListItem extends StatelessWidget {
  final DocumentRequest request;

  const _RequestListItem({required this.request});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
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
                    color: colorScheme.onSurfaceVariant,
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
        color = AppColors.completed;
        icon = Icons.done_all;
        break;
      case DocumentRequestStatus.rejected:
      case DocumentRequestStatus.cancelled:
        color = AppColors.error;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DocumentRequestStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    switch (status) {
      case DocumentRequestStatus.pending:
        text = 'Ausstehend';
        color = AppColors.warning;
        break;
      case DocumentRequestStatus.inReview:
        text = 'In Bearbeitung';
        color = AppColors.info;
        break;
      case DocumentRequestStatus.approved:
        text = 'Genehmigt';
        color = AppColors.success;
        break;
      case DocumentRequestStatus.ready:
        text = 'Abholbereit';
        color = AppColors.success;
        break;
      case DocumentRequestStatus.delivered:
        text = 'Abgeholt';
        color = AppColors.completed;
        break;
      case DocumentRequestStatus.rejected:
        text = 'Abgelehnt';
        color = AppColors.error;
        break;
      case DocumentRequestStatus.cancelled:
        text = 'Storniert';
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
