import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:etkinlik_kesif_uygulamasi/core/theme/app_colors.dart';
import 'package:etkinlik_kesif_uygulamasi/core/theme/app_theme.dart';
import 'package:etkinlik_kesif_uygulamasi/core/theme/app_typography.dart';
import 'package:etkinlik_kesif_uygulamasi/core/theme/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppColors.isDarkMode = true;
  });

  group('Design System & Theme Tests', () {
    test('AppColors tokens have expected hex values matching reference', () {
      expect(AppColors.background, const Color(0xFF14111F));
      expect(AppColors.surface, const Color(0xFF1E1A2B));
      expect(AppColors.accentGreen, const Color(0xFFC5F5A3));
      expect(AppColors.accentGreenText, const Color(0xFF14111F));
      expect(AppColors.accentPurple, const Color(0xFF8B6FD1));
      expect(AppColors.textPrimary, const Color(0xFFFFFFFF));
    });

    test('AppTypography builds without error', () {
      expect(AppTypography.headingLarge.fontSize, 22);
      expect(AppTypography.buttonPrimary.fontWeight, FontWeight.bold);
    });

    test('AppTheme.darkTheme defines correct Dark Mode properties', () {
      final theme = AppTheme.darkTheme;

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.darkBackground);
      expect(theme.colorScheme.primary, AppColors.accentGreen);
      expect(theme.colorScheme.surface, AppColors.darkSurface);
      expect(theme.cardTheme.color, AppColors.darkSurface);
      expect(theme.useMaterial3, true);
    });

    test('AppTheme.lightTheme defines correct Light Mode properties', () {
      final theme = AppTheme.lightTheme;

      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppColors.lightBackground);
      expect(theme.colorScheme.surface, AppColors.lightSurface);
      expect(theme.cardTheme.color, AppColors.lightSurface);
      expect(theme.useMaterial3, true);
    });

    test('ThemeProvider toggles between dark and light mode and persists preference', () async {
      final provider = ThemeProvider();
      expect(provider.isDarkMode, true);
      expect(provider.themeMode, ThemeMode.dark);
      expect(AppColors.background, AppColors.darkBackground);

      await provider.toggleTheme();
      expect(provider.isDarkMode, false);
      expect(provider.themeMode, ThemeMode.light);
      expect(AppColors.background, AppColors.lightBackground);

      // Verify persistence in a new ThemeProvider instance
      final newProvider = ThemeProvider();
      await newProvider.loadTheme();
      expect(newProvider.isDarkMode, false);
      expect(newProvider.themeMode, ThemeMode.light);
    });
  });
}

