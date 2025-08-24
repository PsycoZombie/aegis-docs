import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides an instance of [SettingsService] for dependency injection.
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

/// Defines the available durations for the automatic cleanup of exported files.
// ignore: public_member_api_docs
enum CleanupDuration { fiveMinutes, oneHour, oneDay, sevenDays, never }

/// A service for saving and loading user-configurable settings.
///
/// This class acts as a wrapper around [SharedPreferences] to provide a
/// type-safe API for app settings.
class SettingsService {
  /// The key used to store the cleanup duration in SharedPreferences.
  static const String _cleanupDurationKey = AppConstants.keyCleanupDuration;

  /// Saves the user's selected [CleanupDuration] to persistent storage.
  ///
  /// The enum is stored by its index.
  Future<void> saveCleanupDuration(CleanupDuration duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cleanupDurationKey, duration.index);
  }

  /// Loads the user's selected [CleanupDuration] from persistent storage.
  ///
  /// If no value is found, it defaults to [CleanupDuration.oneDay].
  Future<CleanupDuration> loadCleanupDuration() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to 'oneDay' if the preference is not set.
    final index =
        prefs.getInt(_cleanupDurationKey) ?? CleanupDuration.oneDay.index;

    // Ensure the index is valid before accessing the enum values.
    if (index >= 0 && index < CleanupDuration.values.length) {
      return CleanupDuration.values[index];
    }
    // Fallback to the default if the stored index is out of bounds.
    return CleanupDuration.oneDay;
  }

  /// Converts a [CleanupDuration] enum value into its equivalent in minutes.
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
        // Return a very large number (100 years) as a sentinel value.
        // The calling code should explicitly check for
        //'never' and not rely on this value.
        return 100 * 365 * 24 * 60;
    }
  }
}
