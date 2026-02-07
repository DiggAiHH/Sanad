import 'package:flutter/material.dart';
import 'package:sanad_core/sanad_core.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../display/avatar.dart';

/// Card displaying staff member information
class StaffCard extends StatelessWidget {
  final StaffMember staff;
  final VoidCallback? onTap;
  final VoidCallback? onChat;
  final bool showStatus;

  const StaffCard({
    super.key,
    required this.staff,
    this.onTap,
    this.onChat,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  AppAvatar(
                    name: staff.user.fullName,
                    imageUrl: staff.user.avatarUrl,
                    size: 56,
                  ),
                  if (showStatus)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: staff.isAvailable
                              ? AppColors.success
                              : AppColors.textSecondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.displayName,
                      style: AppTextStyles.h6,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRoleText(),
                      style: AppTextStyles.bodySmall,
                    ),
                    if (staff.roomNumber != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.room_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Raum ${staff.roomNumber}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Actions
              if (onChat != null)
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: onChat,
                  color: AppColors.primary,
                  tooltip: 'Nachricht senden',
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleText() {
    switch (staff.user.role) {
      case UserRole.doctor:
        return staff.specialization?.name ?? 'Arzt';
      case UserRole.mfa:
        return 'Medizinische Fachangestellte';
      case UserRole.staff:
        return 'Mitarbeiter';
      default:
        return '';
    }
  }
}
