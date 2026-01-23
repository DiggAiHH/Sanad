import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Sanad text styles
class AppTextStyles {
  AppTextStyles._();

  static final _baseFont = GoogleFonts.inter();

  // Headlines
  static TextStyle get headlineLarge => h1;
  static TextStyle get headlineMedium => h2;
  static TextStyle get headlineSmall => h3;

  static TextStyle get h1 => _baseFont.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get h2 => _baseFont.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get h3 => _baseFont.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get h4 => _baseFont.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get h5 => _baseFont.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get h6 => _baseFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  // Titles
  static TextStyle get titleLarge => h4;
  static TextStyle get titleMedium => h5;
  static TextStyle get titleSmall => h6;

  // Display
  static TextStyle get displayLarge => h1;
  static TextStyle get displayMedium => h2;
  static TextStyle get displaySmall => h3;

  // Body text
  static TextStyle get bodyLarge => _baseFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _baseFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => _baseFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // Labels
  static TextStyle get labelLarge => _baseFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get labelMedium => _baseFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get labelSmall => _baseFont.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // Special styles
  static TextStyle get ticketNumber => _baseFont.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        height: 1,
        letterSpacing: 2,
      );

  static TextStyle get waitTime => _baseFont.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get button => _baseFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
        height: 1.4,
        letterSpacing: 0.5,
      );
}
