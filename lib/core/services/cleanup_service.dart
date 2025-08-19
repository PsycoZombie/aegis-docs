import 'package:aegis_docs/core/services/native_compression_service.dart';
import 'package:aegis_docs/core/services/settings_service.dart';
import 'package:flutter/foundation.dart';

class CleanupService {
  final NativeCompressionService _nativeService;
  final SettingsService _settingsService;

  CleanupService({
    required NativeCompressionService nativeService,
    required SettingsService settingsService,
  }) : _nativeService = nativeService,
       _settingsService = settingsService;

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
    } catch (e) {
      debugPrint('Error during cleanup service: $e');
    }
  }
}
