import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';

/// Manages Dark and Light theme mode state and persists the user's preference locally.
class ThemeProvider extends ChangeNotifier {
  static const String _themePrefKey = 'app_theme_is_dark';

  bool _isDarkMode = true;

  ThemeProvider({bool initialIsDark = true}) : _isDarkMode = initialIsDark {
    AppColors.isDarkMode = _isDarkMode;
  }

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Loads saved theme preference from [SharedPreferences].
  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_themePrefKey);
      if (saved != null && saved != _isDarkMode) {
        _isDarkMode = saved;
        AppColors.isDarkMode = _isDarkMode;
        notifyListeners();
      }
    } catch (_) {
      // Fallback to default dark theme if storage fails
    }
  }

  /// Toggles between Dark and Light theme and persists the selection.
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    AppColors.isDarkMode = _isDarkMode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePrefKey, _isDarkMode);
    } catch (_) {
      // Ignore persistence errors
    }
  }
}

