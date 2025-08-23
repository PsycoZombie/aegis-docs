import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides an instance of [NativeCleanupService] for dependency injection.
final nativeCleanupServiceProvider = Provider<NativeCleanupService>((ref) {
  return NativeCleanupService();
});

/// A service that acts as a bridge to a native
/// implementation for file cleanup tasks.
class NativeCleanupService {
  /// The method channel used to communicate with the native platform.
  static const _platform = MethodChannel(AppConstants.platformChannelName);

  /// Invokes a native method to clean up expired
  /// files from the app's public export directory.
  ///
  /// This is a fire-and-forget call; failures are logged but not thrown.
  Future<void> cleanupExportedFiles({required int expirationInMinutes}) async {
    try {
      await _platform.invokeMethod('cleanupExportedFiles', {
        'expirationInMinutes': expirationInMinutes,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to run native cleanup: ${e.message}');
    }
  }
}
