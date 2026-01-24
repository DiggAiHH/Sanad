import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';
import 'package:url_launcher/url_launcher.dart';

final publicPracticeProvider =
    FutureProvider.autoDispose<PublicPractice>((ref) async {
  final service = ref.watch(publicPracticeServiceProvider);
  return service.getDefaultPractice();
});

/// Practice information screen.
class InfoScreen extends ConsumerWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final practiceAsync = ref.watch(publicPracticeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Praxis-Information',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: practiceAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ScreenState(
            errorMessage: 'Praxis-Informationen konnten nicht geladen werden.',
            errorActionLabel: 'Erneut versuchen',
            onAction: () => ref.refresh(publicPracticeProvider),
            child: const SizedBox.shrink(),
          ),
          data: (practice) {
            final openingHours =
                practice.openingHours ?? 'Bitte telefonisch erfragen.';
            final openingLines = openingHours
                .split(',')
                .map((line) => line.trim())
                .where((line) => line.isNotEmpty)
                .toList();
            final website = practice.website?.trim();
            final websiteUri = (website == null || website.isEmpty)
                ? null
                : Uri.tryParse(
                    website.startsWith('http://') ||
                            website.startsWith('https://')
                        ? website
                        : 'https://$website',
                  );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Practice Header
                  Container(
                    padding: AppSpacing.cardPaddingLarge,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.large,
                      boxShadow: AppShadows.small,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: AppRadius.large,
                          ),
                          child: const Icon(
                            Icons.local_hospital,
                            color: AppColors.textOnPrimary,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                practice.name,
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Durchschnittliche Wartezeit: '
                                '${practice.averageWaitTimeMinutes} Min.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Opening Hours
                  _SectionHeader(title: 'Öffnungszeiten'),
                  const SizedBox(height: 12),
                  _InfoCard(
                    child: Column(
                      children: openingLines.isEmpty
                          ? [
                              Text(
                                'Bitte telefonisch erfragen.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ]
                          : openingLines.map((line) {
                              final parts = line.split(':');
                              final label = parts.first.trim();
                              final hours = parts.length > 1
                                  ? parts.sublist(1).join(':').trim()
                                  : '';
                              return Column(
                                children: [
                                  _OpeningHoursRow(
                                    day: label,
                                    hours: hours.isEmpty ? line : hours,
                                  ),
                                  if (line != openingLines.last)
                                    const Divider(height: 24),
                                ],
                              );
                            }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact
                  _SectionHeader(title: 'Kontakt'),
                  const SizedBox(height: 12),
                  _ContactCard(
                    icon: Icons.phone,
                    title: 'Telefon',
                    value: practice.phone,
                    onTap: () async {
                      final uri = Uri(scheme: 'tel', path: practice.phone);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _ContactCard(
                    icon: Icons.email,
                    title: 'E-Mail',
                    value: practice.email,
                    onTap: () async {
                      final uri = Uri(
                        scheme: 'mailto',
                        path: practice.email,
                        query: 'subject=Anfrage%20Praxis',
                      );
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                  ),
                  if (websiteUri != null) ...[
                    const SizedBox(height: 12),
                    _ContactCard(
                      icon: Icons.public,
                      title: 'Website',
                      value: website!,
                      onTap: () async {
                        if (await canLaunchUrl(websiteUri)) {
                          await launchUrl(websiteUri);
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Address
                  _SectionHeader(title: 'Adresse'),
                  const SizedBox(height: 12),
                  _InfoCard(
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            practice.address,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.directions, color: AppColors.primary),
                          onPressed: () async {
                            final encoded = Uri.encodeComponent(practice.address);
                            final uri = Uri.parse('geo:0,0?q=$encoded');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Services
                  _SectionHeader(title: 'Leistungen'),
                  const SizedBox(height: 12),
                  _InfoCard(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _ServiceChip(label: 'Allgemeinmedizin'),
                        _ServiceChip(label: 'Innere Medizin'),
                        _ServiceChip(label: 'Vorsorgeuntersuchungen'),
                        _ServiceChip(label: 'Impfungen'),
                        _ServiceChip(label: 'Labordiagnostik'),
                        _ServiceChip(label: 'EKG'),
                        _ServiceChip(label: 'Ultraschall'),
                        _ServiceChip(label: 'Hausbesuche'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Emergency Info
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.emergency, color: AppColors.error),
                            const SizedBox(width: 12),
                            Text(
                              'Notfall',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Bei lebensbedrohlichen Notfällen rufen Sie bitte sofort den Notruf 112 an.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Ärztlicher Bereitschaftsdienst: 116 117',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;

  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPaddingLarge,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _OpeningHoursRow extends StatelessWidget {
  final String day;
  final String hours;
  final bool isClosed;

  const _OpeningHoursRow({
    required this.day,
    required this.hours,
    this.isClosed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          hours,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isClosed ? AppColors.error : AppColors.success,
            fontWeight: isClosed ? FontWeight.normal : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.medium,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.medium,
        child: Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            borderRadius: AppRadius.medium,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  borderRadius: AppRadius.small,
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      value,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final String label;

  const _ServiceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
