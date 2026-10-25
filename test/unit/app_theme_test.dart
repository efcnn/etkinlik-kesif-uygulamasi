import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:etkinlik_kesif_uygulamasi/core/theme/app_colors.dart';
import 'package:etkinlik_kesif_uygulamasi/core/theme/app_theme.dart';
import 'package:etkinlik_kesif_uygulamasi/core/theme/app_typography.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

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
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.primary, AppColors.accentGreen);
      expect(theme.colorScheme.surface, AppColors.surface);
      expect(theme.cardTheme.color, AppColors.card);
      expect(theme.useMaterial3, true);
    });
  });
}

