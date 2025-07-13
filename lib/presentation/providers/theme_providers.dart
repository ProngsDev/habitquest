import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';

/// Provider for theme mode (light/dark)
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) => 
    ThemeModeNotifier());

/// Provider for current theme data
final currentThemeProvider = Provider<CupertinoThemeData>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  
  switch (themeMode) {
    case ThemeMode.light:
      return AppTheme.lightTheme;
    case ThemeMode.dark:
      return AppTheme.darkTheme;
    case ThemeMode.system:
      // For now, default to light theme
      // In a real app, you'd check the system theme
      return AppTheme.lightTheme;
  }
});

/// Provider for checking if dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  
  switch (themeMode) {
    case ThemeMode.light:
      return false;
    case ThemeMode.dark:
      return true;
    case ThemeMode.system:
      // For now, default to false
      // In a real app, you'd check the system theme
      return false;
  }
});

/// Notifier for managing theme mode
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void setLightMode() {
    state = ThemeMode.light;
  }

  void setDarkMode() {
    state = ThemeMode.dark;
  }

  void setSystemMode() {
    state = ThemeMode.system;
  }

  void toggleTheme() {
    switch (state) {
      case ThemeMode.light:
        state = ThemeMode.dark;
      case ThemeMode.dark:
        state = ThemeMode.light;
      case ThemeMode.system:
        state = ThemeMode.light;
    }
  }
}
