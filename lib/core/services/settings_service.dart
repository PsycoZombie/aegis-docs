import 'package:shared_preferences/shared_preferences.dart';

enum CleanupDuration { fiveMinutes, oneHour, oneDay, sevenDays, never }

class SettingsService {
  static const _cleanupDurationKey = 'cleanup_duration';

  Future<void> saveCleanupDuration(CleanupDuration duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cleanupDurationKey, duration.index);
  }

  Future<CleanupDuration> loadCleanupDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final index =
        prefs.getInt(_cleanupDurationKey) ?? CleanupDuration.oneDay.index;
    return CleanupDuration.values[index];
  }

  int getDurationInMinutes(CleanupDuration cleanup) {
    switch (cleanup) {
      case CleanupDuration.fiveMinutes:
        return 5;
      case CleanupDuration.oneHour:
        return 60;
      case CleanupDuration.oneDay:
        return 24 * 60;
      case CleanupDuration.sevenDays:
        return 7 * 24 * 60;
      case CleanupDuration.never:
        return 100 * 365 * 24 * 60;
    }
  }
}
