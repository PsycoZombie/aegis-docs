import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Provides an instance of [NativePdfCompressionService]
/// for dependency injection.
final nativePdfCompressionServiceProvider =
    Provider<NativePdfCompressionService>((ref) {
      return NativePdfCompressionService();
    });

/// A service that acts as a bridge to a high-performance native implementation
/// for PDF compression using MuPDF.
class NativePdfCompressionService {
  /// The method channel used to communicate with the native platform.
  static const _platform = MethodChannel(AppConstants.platformChannelName);

  /// Invokes a native method to compress a PDF file using MuPDF.
  ///
  /// [filePath]: The path of the source PDF to compress.
  /// [sizeLimit]: The target size in kilobytes (e.g., 1024 for 1MB).
  /// [preserveText]: Whether to avoid converting
  /// text to images, which maintains
  /// text selectability but may result in a larger file size.
  ///
  /// Throws an [Exception] on failure. Returns the path
  /// to the compressed temporary file.
  Future<String> compressPdf({
    required String filePath,
    required int sizeLimit,
    required bool preserveText,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFileName = 'temp_compressed_${const Uuid().v4()}.pdf';
      final outputPath = '${tempDir.path}/$tempFileName';

      // The native method now returns a Map.
      final result = await _platform.invokeMethod<Map<Object?, Object?>>(
        AppConstants.methodCompressPdf,
        {
          AppConstants.paramFilePath: filePath,
          AppConstants.paramOutputPath: outputPath,
          AppConstants.paramSizeLimit: sizeLimit,
          AppConstants.paramPreserveText: preserveText ? 1 : 0,
        },
      );

      // Check the status from the native result.
      if (result?['status'] == 'success') {
        final path = result?['path'] as String?;
        if (path != null && path.isNotEmpty) {
          return path;
        }
        throw Exception(
          'Native compression succeeded but returned an empty path.',
        );
      } else {
        // If the status is 'error', throw an exception with the native message.
        final message =
            result?['message'] as String? ??
            'An unknown native error occurred.';
        throw Exception(message);
      }
    } on PlatformException catch (e) {
      throw Exception('Failed to communicate with native code: ${e.message}');
    }
  }
}
