import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

/// A key for storing the user's theme preference in SharedPreferences.
const _themePrefsKey = 'appTheme';

/// Manages the application's theme, persisting the user's choice.
///
/// This provider determines the initial theme based on system settings or
/// the user's last saved preference. It allows toggling between light and
/// dark themes and saves the choice to local storage.
@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  late SharedPreferences _prefs;

  @override
  Future<ThemeMode> build() async {
    _prefs = await SharedPreferences.getInstance();
    return _loadThemeFromPrefs();
  }

  /// Loads the saved [ThemeMode] from [SharedPreferences].
  ///
  /// If no theme is saved, it defaults to the system's current theme.
  ThemeMode _loadThemeFromPrefs() {
    final themeIndex = _prefs.getInt(_themePrefsKey);
    if (themeIndex == null) {
      // Use the platform brightness as the default if no preference is saved.
      final brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
    return ThemeMode.values[themeIndex];
  }

  /// Toggles the application theme between light and dark modes.
  ///
  /// Persists the new theme choice to [SharedPreferences].
  Future<void> toggleTheme() async {
    // If the state is not yet loaded, do nothing.
    if (state.valueOrNull == null) return;

    final newTheme = state.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;

    await _prefs.setInt(_themePrefsKey, newTheme.index);

    state = AsyncValue.data(newTheme);
  }
}
