import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_ui/sanad_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Practice information screen.
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Practice Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.local_hospital,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Praxis Musterstadt',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Allgemeinmedizin & Innere Medizin',
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
                  children: [
                    _OpeningHoursRow(day: 'Montag', hours: '08:00 - 12:00, 14:00 - 18:00'),
                    const Divider(height: 24),
                    _OpeningHoursRow(day: 'Dienstag', hours: '08:00 - 12:00, 14:00 - 18:00'),
                    const Divider(height: 24),
                    _OpeningHoursRow(day: 'Mittwoch', hours: '08:00 - 12:00'),
                    const Divider(height: 24),
                    _OpeningHoursRow(day: 'Donnerstag', hours: '08:00 - 12:00, 14:00 - 18:00'),
                    const Divider(height: 24),
                    _OpeningHoursRow(day: 'Freitag', hours: '08:00 - 13:00'),
                    const Divider(height: 24),
                    _OpeningHoursRow(day: 'Samstag', hours: 'Geschlossen', isClosed: true),
                    const Divider(height: 24),
                    _OpeningHoursRow(day: 'Sonntag', hours: 'Geschlossen', isClosed: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Contact
              _SectionHeader(title: 'Kontakt'),
              const SizedBox(height: 12),
              _ContactCard(
                icon: Icons.phone,
                title: 'Telefon',
                value: '+49 123 456789',
                onTap: () async {
                  final uri = Uri(scheme: 'tel', path: '+49123456789');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),
              const SizedBox(height: 12),
              _ContactCard(
                icon: Icons.email,
                title: 'E-Mail',
                value: 'praxis@musterstadt.de',
                onTap: () async {
                  final uri = Uri(
                    scheme: 'mailto',
                    path: 'praxis@musterstadt.de',
                    query: 'subject=Anfrage%20Praxis',
                  );
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),
              const SizedBox(height: 12),
              _ContactCard(
                icon: Icons.language,
                title: 'Website',
                value: 'www.praxis-musterstadt.de',
                onTap: () async {
                  final uri = Uri.parse('https://www.praxis-musterstadt.de');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Musterstraße 123',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '12345 Musterstadt',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.directions, color: AppColors.primary),
                      onPressed: () async {
                        final uri = Uri.parse('geo:0,0?q=Musterstraße+123,+12345+Musterstadt');
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
                  children: [
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
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
