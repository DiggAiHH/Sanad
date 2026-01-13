import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Status badge widget
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final bool outlined;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.outlined = false,
  });

  // Factory constructors for common statuses
  factory StatusBadge.success(String text, {IconData? icon}) {
    return StatusBadge(text: text, color: AppColors.success, icon: icon);
  }

  factory StatusBadge.warning(String text, {IconData? icon}) {
    return StatusBadge(text: text, color: AppColors.warning, icon: icon);
  }

  factory StatusBadge.error(String text, {IconData? icon}) {
    return StatusBadge(text: text, color: AppColors.error, icon: icon);
  }

  factory StatusBadge.info(String text, {IconData? icon}) {
    return StatusBadge(text: text, color: AppColors.info, icon: icon);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: outlined ? Border.all(color: color) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
