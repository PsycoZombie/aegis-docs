import 'package:aegis_docs/core/services/native_cleanup_service.dart';
import 'package:aegis_docs/core/services/settings_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides an instance of [CleanupService] for dependency injection.
final cleanupServiceProvider = Provider<CleanupService>((ref) {
  return CleanupService(
    nativeService: ref.watch(nativeCleanupServiceProvider),
    settingsService: ref.watch(settingsServiceProvider),
  );
});

/// A service responsible for cleaning up temporary files created by the app.
class CleanupService {
  /// Creates an instance of [CleanupService].
  CleanupService({
    required NativeCleanupService nativeService,
    required SettingsService settingsService,
  }) : _nativeService = nativeService,
       _settingsService = settingsService;

  final NativeCleanupService _nativeService;
  final SettingsService _settingsService;

  /// Runs the cleanup process based on the user's saved preferences.
  Future<void> runCleanup() async {
    try {
      debugPrint('Running cleanup service...');
      final durationChoice = await _settingsService.loadCleanupDuration();

      if (durationChoice == CleanupDuration.never) {
        debugPrint('Cleanup skipped: user setting is "Never".');
        return;
      }

      final expirationInMinutes = _settingsService.getDurationInMinutes(
        durationChoice,
      );

      await _nativeService.cleanupExportedFiles(
        expirationInMinutes: expirationInMinutes,
      );

      debugPrint('Cleanup call to native code complete.');
    } on Exception catch (e) {
      debugPrint('Error during cleanup service: $e');
    }
  }
}
