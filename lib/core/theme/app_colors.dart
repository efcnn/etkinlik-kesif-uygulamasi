import 'package:flutter/material.dart';

/// Design tokens for the application's visual language.
/// Supports both the primary Dark Theme and an adaptive Light Theme.
class AppColors {
  AppColors._();

  /// Tracks whether Dark Mode is currently active so token getters adapt seamlessly.
  static bool isDarkMode = true;

  // --- Dark Palette Tokens ---
  static const Color darkBackground = Color(0xFF14111F);
  static const Color darkSurface = Color(0xFF1E1A2B);
  static const Color darkSurfaceLight = Color(0xFF272238);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9E9AA7);
  static const Color darkTextMuted = Color(0xFF6E697C);
  static const Color darkDivider = Color(0xFF2B253C);

  // --- Light Palette Tokens ---
  static const Color lightBackground = Color(0xFFF6F5FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceLight = Color(0xFFECE9F5);
  static const Color lightTextPrimary = Color(0xFF14111F);
  static const Color lightTextSecondary = Color(0xFF534E66);
  static const Color lightTextMuted = Color(0xFF7D7890);
  static const Color lightDivider = Color(0xFFE4E0F0);

  // --- Adaptive Surface & Text Getters ---
  static Color get background => isDarkMode ? darkBackground : lightBackground;
  static Color get surface => isDarkMode ? darkSurface : lightSurface;
  static Color get surfaceLight => isDarkMode ? darkSurfaceLight : lightSurfaceLight;
  static Color get card => isDarkMode ? darkSurface : lightSurface;

  static Color get textPrimary => isDarkMode ? darkTextPrimary : lightTextPrimary;
  static Color get textSecondary => isDarkMode ? darkTextSecondary : lightTextSecondary;
  static Color get textMuted => isDarkMode ? darkTextMuted : lightTextMuted;

  static Color get divider => isDarkMode ? darkDivider : lightDivider;
  static Color get border => isDarkMode ? darkDivider : lightDivider;
  static Color get inputBackground => isDarkMode ? darkSurface : lightSurface;

  // Primary Accent: Soft lime / mint green
  static const Color accentGreen = Color(0xFFC5F5A3);
  static const Color accentGreenDark = Color(0xFFAFE08B);
  static const Color accentGreenText = Color(0xFF14111F); // Dark text on green

  // Secondary Accent: Muted purple
  static const Color accentPurple = Color(0xFF8B6FD1);
  static const Color accentPurpleDark = Color(0xFF6B4FA0);
  static const Color accentPurpleLight = Color(0xFFA58DE0);

  // Status & Badges
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF51CF66);
  static const Color onlineBadge = Color(0xFF5CE1E6);
  static const Color favoriteRed = Color(0xFFFF5252);

  // Dark gradient for image overlays (ensures readability on event photos in both themes)
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

