import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier that manages the app's [ThemeMode].
///
/// Supports light, dark, and system (follows device setting) modes.
///
/// Requirements: 17.7
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  /// Switch to light mode.
  void setLight() => state = ThemeMode.light;

  /// Switch to dark mode.
  void setDark() => state = ThemeMode.dark;

  /// Follow the device system setting.
  void setSystem() => state = ThemeMode.system;

  /// Toggle between light and dark (ignores system).
  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

/// Provider for the current [ThemeMode].
///
/// Usage:
/// ```dart
/// final themeMode = ref.watch(themeModeProvider);
/// ref.read(themeModeProvider.notifier).setDark();
/// ```
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
