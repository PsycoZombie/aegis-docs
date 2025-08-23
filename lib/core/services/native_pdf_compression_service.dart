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
  /// [preserveText]: Whether to avoid
  /// converting text to images, which maintains
  /// text selectability but may result in a larger file size.
  ///
  /// Throws an [Exception] on failure.
  /// Returns the path to the compressed temporary file.
  Future<String> compressPdf({
    required String filePath,
    required int sizeLimit,
    required bool preserveText,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFileName = 'temp_compressed_${const Uuid().v4()}.pdf';
      final outputPath = '${tempDir.path}/$tempFileName';

      final result = await _platform.invokeMethod('compressPdf', {
        'filePath': filePath,
        'outputPath': outputPath,
        'sizeLimit': sizeLimit,
        'preserveText': preserveText ? 1 : 0, // Pass bool as int
      });

      final resultPath = result as String?;

      if (resultPath == null || resultPath.isEmpty) {
        throw Exception('Native compression returned an empty or null path.');
      }

      return resultPath;
    } on PlatformException catch (e) {
      throw Exception('Failed to compress PDF via native code: ${e.message}');
    }
  }
}
