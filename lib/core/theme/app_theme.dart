import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.accentGreen,
        onPrimary: AppColors.accentGreenText,
        secondary: AppColors.accentPurple,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headingMedium.copyWith(color: AppColors.darkTextPrimary),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGreen,
          foregroundColor: AppColors.accentGreenText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: AppTypography.buttonPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentGreen,
          side: const BorderSide(color: AppColors.accentGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: AppTypography.titleLarge.copyWith(color: AppColors.accentGreen),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceLight,
        selectedColor: AppColors.accentGreen,
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
        secondaryLabelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.accentGreenText),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 24,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.darkTextSecondary,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.accentPurple,
        onPrimary: Colors.white,
        secondary: AppColors.accentGreenDark,
        onSecondary: AppColors.accentGreenText,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headingMedium.copyWith(color: AppColors.lightTextPrimary),
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGreen,
          foregroundColor: AppColors.accentGreenText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: AppTypography.buttonPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentPurpleDark,
          side: const BorderSide(color: AppColors.accentPurple, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: AppTypography.titleLarge.copyWith(color: AppColors.accentPurpleDark),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurfaceLight,
        selectedColor: AppColors.accentGreen,
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextSecondary),
        secondaryLabelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.accentGreenText),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 24,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.lightTextSecondary,
      ),
    );
  }
}

