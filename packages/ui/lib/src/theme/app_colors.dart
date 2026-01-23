import 'package:flutter/material.dart';

/// Sanad app color palette
class AppColors {
  AppColors._();

  // Primary - Medical Blue
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF1565C0);

  // Secondary - Teal
  static const Color secondary = Color(0xFF00897B);
  static const Color secondaryLight = Color(0xFF4DB6AC);
  static const Color secondaryDark = Color(0xFF00695C);

  // Accent
  static const Color accent = Color(0xFF26C6DA);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Queue status colors
  static const Color waiting = Color(0xFFFFA726);
  static const Color called = Color(0xFF42A5F5);
  static const Color inProgress = Color(0xFF66BB6A);
  static const Color completed = Color(0xFF9E9E9E);

  // Priority colors
  static const Color priorityNormal = Color(0xFF4CAF50);
  static const Color priorityUrgent = Color(0xFFFF9800);
  static const Color priorityEmergency = Color(0xFFF44336);
  
  // Priority levels (1-5 scale)
  static const Color priorityCritical = Color(0xFFF44336);
  static const Color priorityHigh = Color(0xFFFF5722);
  static const Color priorityMedium = Color(0xFFFF9800);
  static const Color priorityLow = Color(0xFF8BC34A);

  // Neutral colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F8);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = divider;

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkDivider = Color(0xFF424242);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);

  /// Get ticket status color
  static Color getTicketStatusColor(String status) {
    switch (status) {
      case 'waiting':
        return waiting;
      case 'called':
        return called;
      case 'in_progress':
        return inProgress;
      case 'completed':
        return completed;
      default:
        return textSecondary;
    }
  }

  /// Get priority color
  static Color getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return priorityUrgent;
      case 'emergency':
        return priorityEmergency;
      default:
        return priorityNormal;
    }
  }
}
