import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

const _themePrefsKey = 'appTheme';

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  late SharedPreferences _prefs;

  @override
  Future<ThemeMode> build() async {
    _prefs = await SharedPreferences.getInstance();
    return _loadThemeFromPrefs();
  }

  ThemeMode _loadThemeFromPrefs() {
    final themeIndex = _prefs.getInt(_themePrefsKey);
    if (themeIndex == null) {
      final brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
    return ThemeMode.values[themeIndex];
  }

  Future<void> toggleTheme() async {
    final newTheme = state.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;

    await _prefs.setInt(_themePrefsKey, newTheme.index);

    state = AsyncValue.data(newTheme);
  }
}
