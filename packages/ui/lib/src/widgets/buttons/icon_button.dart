import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Custom icon button with optional badge
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final int? badgeCount;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.badgeCount,
    this.iconColor,
    this.backgroundColor,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor ?? AppColors.textPrimary),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        iconSize: size * 0.5,
      ),
    );

    if (badgeCount != null && badgeCount! > 0) {
      button = Badge(
        label: Text(
          badgeCount! > 99 ? '99+' : badgeCount.toString(),
          style: const TextStyle(fontSize: 10),
        ),
        child: button,
      );
    }

    return button;
  }
}
