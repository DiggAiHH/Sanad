import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Avatar widget with fallback to initials
class AppAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 40,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials();
    final bgColor = backgroundColor ?? _generateColor();

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildFallback(initials, bgColor),
          errorWidget: (context, url, error) =>
              _buildFallback(initials, bgColor),
        ),
      );
    }

    return _buildFallback(initials, bgColor);
  }

  Widget _buildFallback(String initials, Color bgColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textOnPrimary,
            fontSize: size * 0.35,
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  Color _generateColor() {
    final hash = name.hashCode;
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.info,
      const Color(0xFF9C27B0),
      const Color(0xFFE91E63),
      const Color(0xFF00BCD4),
      const Color(0xFF795548),
    ];
    return colors[hash.abs() % colors.length];
  }
}
