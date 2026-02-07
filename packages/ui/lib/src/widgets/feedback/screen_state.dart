import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'empty_and_loading.dart';
import '../layout/loading_overlay.dart';

/// Screen-level state handler for loading, error, and empty content.
class ScreenState extends StatelessWidget {
  /// Whether the screen is currently loading.
  final bool isLoading;

  /// Whether the screen has no content to render.
  final bool isEmpty;

  /// Optional error message to render in the error state.
  final String? errorMessage;

  /// Optional message to show under the loading indicator.
  final String? loadingMessage;

  /// Optional empty state title.
  final String? emptyTitle;

  /// Optional empty state subtitle.
  final String? emptySubtitle;

  /// Optional empty state action label.
  final String? emptyActionLabel;

  /// Optional error state title override.
  final String? errorTitle;

  /// Optional error state action label.
  final String? errorActionLabel;

  /// Callback for retry or primary action in empty/error states.
  final VoidCallback? onAction;

  /// Main content widget.
  final Widget child;

  const ScreenState({
    super.key,
    required this.child,
    this.isLoading = false,
    this.isEmpty = false,
    this.errorMessage,
    this.loadingMessage,
    this.emptyTitle,
    this.emptySubtitle,
    this.emptyActionLabel,
    this.errorTitle,
    this.errorActionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingIndicator(size: 36),
            if (loadingMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                loadingMessage!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return EmptyStateWidget.error(
        title: errorTitle ?? 'Etwas ist schiefgelaufen',
        subtitle: errorMessage,
        actionLabel: errorActionLabel ?? 'Erneut versuchen',
        onAction: onAction,
      );
    }

    if (isEmpty) {
      return EmptyStateWidget.noData(
        title: emptyTitle ?? 'Keine Daten',
        subtitle: emptySubtitle,
        actionLabel: emptyActionLabel,
        onAction: onAction,
      );
    }

    return child;
  }
}
