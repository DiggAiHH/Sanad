import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Status badge with color coding
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;
  final bool large;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusType.neutral,
    this.large = false,
    this.icon,
  });

  factory StatusBadge.waiting() => const StatusBadge(
        label: 'Wartend',
        type: StatusType.warning,
        icon: Icons.hourglass_empty,
      );

  factory StatusBadge.called() => const StatusBadge(
        label: 'Aufgerufen',
        type: StatusType.success,
        icon: Icons.notifications_active,
      );

  factory StatusBadge.inProgress() => const StatusBadge(
        label: 'In Behandlung',
        type: StatusType.info,
        icon: Icons.medical_services,
      );

  factory StatusBadge.completed() => const StatusBadge(
        label: 'Abgeschlossen',
        type: StatusType.neutral,
        icon: Icons.check_circle,
      );

  factory StatusBadge.cancelled() => const StatusBadge(
        label: 'Abgebrochen',
        type: StatusType.error,
        icon: Icons.cancel,
      );

  Color get _backgroundColor {
    switch (type) {
      case StatusType.success:
        return AppColors.success.withOpacity(0.1);
      case StatusType.warning:
        return AppColors.warning.withOpacity(0.1);
      case StatusType.error:
        return AppColors.error.withOpacity(0.1);
      case StatusType.info:
        return AppColors.info.withOpacity(0.1);
      case StatusType.neutral:
        return AppColors.textSecondary.withOpacity(0.1);
    }
  }

  Color get _textColor {
    switch (type) {
      case StatusType.success:
        return AppColors.success;
      case StatusType.warning:
        return AppColors.warning;
      case StatusType.error:
        return AppColors.error;
      case StatusType.info:
        return AppColors.info;
      case StatusType.neutral:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 12,
        vertical: large ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(large ? 12 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: large ? 18 : 14, color: _textColor),
            SizedBox(width: large ? 8 : 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: _textColor,
              fontSize: large ? 14 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum StatusType { success, warning, error, info, neutral }

/// Priority indicator dot
class PriorityIndicator extends StatelessWidget {
  final int priority; // 1-5, 1 being highest
  final bool showLabel;

  const PriorityIndicator({
    super.key,
    required this.priority,
    this.showLabel = false,
  });

  Color get _color {
    switch (priority) {
      case 1:
        return AppColors.priorityCritical;
      case 2:
        return AppColors.priorityHigh;
      case 3:
        return AppColors.priorityMedium;
      case 4:
        return AppColors.priorityLow;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _label {
    switch (priority) {
      case 1:
        return 'Kritisch';
      case 2:
        return 'Hoch';
      case 3:
        return 'Mittel';
      case 4:
        return 'Niedrig';
      default:
        return 'Normal';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _label,
            style: TextStyle(
              color: _color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _color.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

/// User avatar with online status
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool showOnlineStatus;
  final bool isOnline;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 48,
    this.showOnlineStatus = false,
    this.isOnline = false,
  });

  String get _initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color get _backgroundColor {
    // Generate consistent color based on name
    final hash = name.hashCode;
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.info,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _backgroundColor,
            shape: BoxShape.circle,
            image: imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: imageUrl == null
              ? Center(
                  child: Text(
                    _initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
        ),
        if (showOnlineStatus)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.success : AppColors.textSecondary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Countdown timer display
class CountdownDisplay extends StatelessWidget {
  final int minutes;
  final int seconds;
  final bool isUrgent;

  const CountdownDisplay({
    super.key,
    required this.minutes,
    required this.seconds,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isUrgent ? AppColors.error : AppColors.primary;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TimeSegment(value: minutes, label: 'Min', color: color),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            ':',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        _TimeSegment(value: seconds, label: 'Sek', color: color),
      ],
    );
  }
}

class _TimeSegment extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _TimeSegment({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
