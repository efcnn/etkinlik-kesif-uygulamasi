import 'package:flutter/material.dart';

/// Design tokens for the application's visual language.
class AppColors {
  AppColors._();

  // Dark background with subtle purple tint
  static const Color background = Color(0xFF14111F);

  // Surface and card containers
  static const Color surface = Color(0xFF1E1A2B);
  static const Color surfaceLight = Color(0xFF272238);
  static const Color card = Color(0xFF1E1A2B);

  // Primary Accent: Soft lime / mint green
  static const Color accentGreen = Color(0xFFC5F5A3);
  static const Color accentGreenDark = Color(0xFFAFE08B);
  static const Color accentGreenText = Color(0xFF14111F); // Dark text on green

  // Secondary Accent: Muted purple
  static const Color accentPurple = Color(0xFF8B6FD1);
  static const Color accentPurpleDark = Color(0xFF6B4FA0);
  static const Color accentPurpleLight = Color(0xFFA58DE0);

  // Typography Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9AA7);
  static const Color textMuted = Color(0xFF6E697C);

  // UI Element Colors
  static const Color divider = Color(0xFF2B253C);
  static const Color border = Color(0xFF2B253C);
  static const Color inputBackground = Color(0xFF1E1A2B);

  // Status & Badges
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF51CF66);
  static const Color onlineBadge = Color(0xFF5CE1E6);
  static const Color favoriteRed = Color(0xFFFF5252);

  // Dark gradient for image overlays (ensures readability)
  static const LinearGradient imageOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x8014111F),
      Color(0xF014111F),
    ],
    stops: [0.3, 0.7, 1.0],
  );
}

