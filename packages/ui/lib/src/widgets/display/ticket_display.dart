import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Large ticket number display for patient-facing screens
class TicketDisplay extends StatelessWidget {
  final String ticketNumber;
  final String? statusText;
  final Color? color;
  final bool animate;

  const TicketDisplay({
    super.key,
    required this.ticketNumber,
    this.statusText,
    this.color,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = color ?? AppColors.primary;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          decoration: BoxDecoration(
            color: displayColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: displayColor, width: 3),
          ),
          child: Text(
            ticketNumber,
            style: AppTextStyles.ticketNumber.copyWith(color: displayColor),
          ),
        ),
        if (statusText != null) ...[
          const SizedBox(height: 16),
          Text(
            statusText!,
            style: AppTextStyles.h5.copyWith(color: displayColor),
          ),
        ],
      ],
    );

    if (animate) {
      content = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.9, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: content,
      );
    }

    return content;
  }
}
