import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Provider für aktive Konsultationen des Patienten.
final activeConsultationsProvider = FutureProvider.autoDispose<List<Consultation>>((ref) async {
  final service = ref.watch(consultationServiceProvider);
  return service.getMyConsultations(
    status: ConsultationStatus.inProgress,
  );
});

/// Screen für Konsultationen (Video, Voice, Chat mit Arzt).
class ConsultationsScreen extends ConsumerWidget {
  const ConsultationsScreen({super.key});

  /// Schritt 6: Ruft 112 Notruf an.
  Future<void> _callEmergency(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Telefon konnte nicht geöffnet werden. Bitte wählen Sie 112 manuell.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Arzt kontaktieren'),
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
      // Schritt 8: Pull-to-Refresh
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeConsultationsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Contact Options
            Text(
              'Wie möchten Sie uns erreichen?',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Video Call Option
            _ContactOptionCard(
              icon: Icons.videocam,
              title: 'Videosprechstunde',
              subtitle: 'Persönliche Beratung per Video',
              color: AppColors.primary,
              availability: 'Mo-Fr 8:00-18:00',
              onTap: () => context.push('/consultation/video'),
            ),
            const SizedBox(height: 12),

            // Voice Call Option
            _ContactOptionCard(
              icon: Icons.phone,
              title: 'Telefonsprechstunde',
              subtitle: 'Rückruf vom Arzt anfordern',
              color: AppColors.success,
              availability: 'Mo-Fr 8:00-18:00',
              onTap: () => context.push('/consultation/voice'),
            ),
            const SizedBox(height: 12),

            // Chat Option
            _ContactOptionCard(
              icon: Icons.chat,
              title: 'Chat',
              subtitle: 'Schriftliche Anfrage an das Praxisteam',
              color: AppColors.info,
              availability: 'Antwort innerhalb 24h',
              onTap: () => context.push('/consultation/chat'),
            ),
            const SizedBox(height: 12),

            // Callback Option
            _ContactOptionCard(
              icon: Icons.phone_callback,
              title: 'Rückruf anfordern',
              subtitle: 'Wir rufen Sie zurück',
              color: AppColors.secondary,
              availability: 'Schnellstmöglich',
              onTap: () => context.push('/consultation/callback'),
            ),
            const SizedBox(height: 32),

            // Active Consultations
            Text(
              'Aktive Gespräche',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildActiveConsultations(context, ref),

            const SizedBox(height: 32),

            // Emergency Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(
                        'Im Notfall',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bei akuten Notfällen rufen Sie bitte die 112 an '
                    'oder suchen Sie die nächste Notaufnahme auf.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _callEmergency(context),
                    icon: Icon(Icons.phone, color: AppColors.error),
                    label: Text(
                      '112 anrufen',
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildActiveConsultations(BuildContext context, WidgetRef ref) {
    final consultationsAsync = ref.watch(activeConsultationsProvider);
    
    return consultationsAsync.when(
      // Schritt 7: Loading State
      loading: () => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      // Schritt 7: Error State
      error: (error, stack) => Container(
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
            TextButton.icon(
              onPressed: () => ref.invalidate(activeConsultationsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
      // Schritt 5: Provider Data
      data: (consultations) {
        if (consultations.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Keine aktiven Gespräche',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: consultations.map((c) => _RealConsultationListItem(
            consultation: c,
            onTap: () => context.push('/consultation/${c.consultationType.name}/${c.id}'),
          )).toList(),
        );
      },
    );
  }
}

class _ContactOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String availability;
  final VoidCallback onTap;

  const _ContactOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.availability,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 12, color: color),
                        const SizedBox(width: 4),
                        Text(
                          availability,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _MockConsultation {
  final ConsultationType type;
  final ConsultationStatus status;
  final String doctorName;
  final String lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  _MockConsultation({
    required this.type,
    required this.status,
    required this.doctorName,
    required this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
  });
}

/// Schritt 5: Real consultation list item using actual Consultation model.
class _RealConsultationListItem extends StatelessWidget {
  final Consultation consultation;
  final VoidCallback onTap;

  const _RealConsultationListItem({
    required this.consultation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (consultation.consultationType) {
      case ConsultationType.videoCall:
        icon = Icons.videocam;
        color = AppColors.primary;
        break;
      case ConsultationType.voiceCall:
        icon = Icons.phone;
        color = AppColors.success;
        break;
      case ConsultationType.chat:
        icon = Icons.chat;
        color = AppColors.info;
        break;
      case ConsultationType.callbackRequest:
        icon = Icons.phone_callback;
        color = AppColors.secondary;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consultation.doctorName ?? 'Arzt',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      consultation.reason ?? 'Konsultation',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(consultation.status),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(ConsultationStatus status) {
    Color bgColor;
    Color textColor;
    String text;
    
    switch (status) {
      case ConsultationStatus.inProgress:
        bgColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        text = 'Aktiv';
        break;
      case ConsultationStatus.waiting:
        bgColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        text = 'Warten';
        break;
      case ConsultationStatus.scheduled:
        bgColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        text = 'Geplant';
        break;
      default:
        bgColor = AppColors.textSecondary.withOpacity(0.1);
        textColor = AppColors.textSecondary;
        text = status.name;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ConsultationListItem extends StatelessWidget {
  final _MockConsultation consultation;
  final VoidCallback onTap;

  const _ConsultationListItem({
    required this.consultation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (consultation.type) {
      case ConsultationType.videoCall:
        icon = Icons.videocam;
        color = AppColors.primary;
        break;
      case ConsultationType.voiceCall:
        icon = Icons.phone;
        color = AppColors.success;
        break;
      case ConsultationType.chat:
        icon = Icons.chat;
        color = AppColors.info;
        break;
      case ConsultationType.callbackRequest:
        icon = Icons.phone_callback;
        color = AppColors.secondary;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consultation.doctorName,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      consultation.lastMessage,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (consultation.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${consultation.unreadCount}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
