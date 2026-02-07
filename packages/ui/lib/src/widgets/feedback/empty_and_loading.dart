import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Empty state widget with illustration and action
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  factory EmptyStateWidget.noData({
    String title = 'Keine Daten',
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      icon: Icons.inbox_outlined,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  factory EmptyStateWidget.noConnection({
    String title = 'Keine Verbindung',
    String subtitle = 'Bitte überprüfen Sie Ihre Internetverbindung.',
    String actionLabel = 'Erneut versuchen',
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      icon: Icons.wifi_off_outlined,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
      iconColor: AppColors.error,
    );
  }

  factory EmptyStateWidget.error({
    String title = 'Etwas ist schiefgelaufen',
    String? subtitle,
    String actionLabel = 'Erneut versuchen',
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      title: title,
      subtitle: subtitle ?? 'Ein Fehler ist aufgetreten. Bitte versuchen Sie es erneut.',
      actionLabel: actionLabel,
      onAction: onAction,
      iconColor: AppColors.error,
    );
  }

  factory EmptyStateWidget.noQueue({
    String title = 'Kein aktives Ticket',
    String subtitle = 'Ziehen Sie ein neues Ticket, um in die Warteschlange einzutreten.',
    String actionLabel = 'Ticket ziehen',
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      icon: Icons.confirmation_number_outlined,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
      iconColor: AppColors.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.textSecondary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: iconColor ?? AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for content placeholders
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
    this.isCircle = false,
  });

  factory SkeletonLoader.circle({double size = 48}) {
    return SkeletonLoader(
      width: size,
      height: size,
      isCircle: true,
    );
  }

  factory SkeletonLoader.card({double height = 120}) {
    return SkeletonLoader(
      height: height,
      borderRadius: 16,
    );
  }

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.isCircle
                ? null
                : BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.5, 1.0],
              colors: [
                AppColors.divider.withOpacity(0.5),
                AppColors.divider.withOpacity(0.8),
                AppColors.divider.withOpacity(0.5),
              ],
              transform: GradientRotation(_animation.value),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton for list items
class SkeletonListItem extends StatelessWidget {
  final bool showAvatar;
  final bool showSubtitle;
  final int lines;

  const SkeletonListItem({
    super.key,
    this.showAvatar = true,
    this.showSubtitle = true,
    this.lines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          if (showAvatar) ...[
            SkeletonLoader.circle(size: 48),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(height: 16, width: 150),
                if (showSubtitle) ...[
                  const SizedBox(height: 8),
                  SkeletonLoader(height: 12, width: lines > 1 ? 200 : 100),
                ],
                if (lines > 2) ...[
                  const SizedBox(height: 8),
                  const SkeletonLoader(height: 12, width: 180),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for queue/ticket cards
class SkeletonQueueCard extends StatelessWidget {
  const SkeletonQueueCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SkeletonLoader(
            width: 60,
            height: 60,
            borderRadius: 16,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(height: 18, width: 120),
                SizedBox(height: 8),
                SkeletonLoader(height: 14, width: 100),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonLoader(height: 16, width: 40),
              SizedBox(height: 8),
              SkeletonLoader(height: 14, width: 60),
            ],
          ),
        ],
      ),
    );
  }
}
