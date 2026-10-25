import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralized typography definitions for consistent text styling.
class AppTypography {
  AppTypography._();

  static final bool _isTest = Platform.environment.containsKey('FLUTTER_TEST');

  static TextStyle _style({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
  }) {
    if (_isTest) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );
    }
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextStyle get displayLarge => _style(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get headingLarge => _style(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.25,
      );

  static TextStyle get headingMedium => _style(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get titleLarge => _style(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => _style(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _style(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get labelSmall => _style(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      );

  static TextStyle get buttonPrimary => _style(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.accentGreenText,
      );
}

