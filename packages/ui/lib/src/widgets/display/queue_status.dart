import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Queue status display widget
class QueueStatus extends StatelessWidget {
  final int waitingCount;
  final int inProgressCount;
  final int? averageWaitMinutes;
  final bool compact;

  const QueueStatus({
    super.key,
    required this.waitingCount,
    required this.inProgressCount,
    this.averageWaitMinutes,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact();
    }
    return _buildFull();
  }

  Widget _buildCompact() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCompactItem(
          icon: Icons.hourglass_empty,
          count: waitingCount,
          color: AppColors.waiting,
        ),
        const SizedBox(width: 16),
        _buildCompactItem(
          icon: Icons.person,
          count: inProgressCount,
          color: AppColors.inProgress,
        ),
      ],
    );
  }

  Widget _buildCompactItem({
    required IconData icon,
    required int count,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: AppTextStyles.labelLarge.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildFull() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildStatItem(
              label: 'Wartend',
              value: waitingCount.toString(),
              icon: Icons.hourglass_empty,
              color: AppColors.waiting,
            ),
            const SizedBox(width: 24),
            _buildStatItem(
              label: 'In Behandlung',
              value: inProgressCount.toString(),
              icon: Icons.person,
              color: AppColors.inProgress,
            ),
            if (averageWaitMinutes != null) ...[
              const SizedBox(width: 24),
              _buildStatItem(
                label: 'Ø Wartezeit',
                value: '$averageWaitMinutes Min.',
                icon: Icons.schedule,
                color: AppColors.info,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.h4.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
