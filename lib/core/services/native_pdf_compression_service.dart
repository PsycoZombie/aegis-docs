import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Defines the possible outcomes of a native PDF compression operation.
enum NativeCompressionStatus {
  /// The compression was successful.
  success,

  /// Text-preserving compression failed,
  /// but the fallback rasterization succeeded.
  successWithFallback,

  /// Compression succeeded, but the file is still larger than the target size.
  errorSizeLimit,

  /// The operation failed due to insufficient device memory.
  errorOutOfMemory,

  /// The operation failed because the PDF is password-protected or corrupted.
  errorBadPassword,

  /// Text-preserving compression failed
  /// because the text content alone is too large.
  errorTextTooLarge,

  /// An unknown or unexpected error occurred.
  errorUnknown,
}

/// A class to hold the structured result from a native compression operation.
class NativeCompressionResult {
  /// Creates an instance of the result.
  const NativeCompressionResult(this.status, this.data);

  /// The status code indicating the outcome of the operation.
  final NativeCompressionStatus status;

  /// The associated data. This will be the output file path on success,
  /// or a detailed error message on failure.
  final String? data;
}

/// Provides an instance of [NativePdfCompressionService]
/// for dependency injection.
final nativePdfCompressionServiceProvider =
    Provider<NativePdfCompressionService>((ref) {
      return NativePdfCompressionService();
    });

/// A service that acts as a bridge to a high-performance native implementation
/// for PDF compression.
class NativePdfCompressionService {
  /// The method channel used to communicate with the native platform.
  static const _platform = MethodChannel(AppConstants.platformChannelName);

  /// Invokes a native method to compress a PDF file.
  ///
  /// Returns a [NativeCompressionResult]
  /// containing the status and relevant data.
  Future<NativeCompressionResult> compressPdf({
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

      // Parse the status and data from the native result map.
      final statusString = result?['status'] as String?;
      final data = result?['data'] as String?;

      switch (statusString) {
        case 'SUCCESS':
          return NativeCompressionResult(NativeCompressionStatus.success, data);
        case 'SUCCESS_WITH_FALLBACK':
          return NativeCompressionResult(
            NativeCompressionStatus.successWithFallback,
            data,
          );
        case 'ERROR_SIZE_LIMIT':
          return NativeCompressionResult(
            NativeCompressionStatus.errorSizeLimit,
            data,
          );
        case 'ERROR_OUT_OF_MEMORY':
          return NativeCompressionResult(
            NativeCompressionStatus.errorOutOfMemory,
            data,
          );
        case 'ERROR_BAD_PASSWORD':
          return NativeCompressionResult(
            NativeCompressionStatus.errorBadPassword,
            data,
          );
        case 'ERROR_TEXT_TOO_LARGE':
          return NativeCompressionResult(
            NativeCompressionStatus.errorTextTooLarge,
            data,
          );
        default:
          return NativeCompressionResult(
            NativeCompressionStatus.errorUnknown,
            data,
          );
      }
    } on PlatformException catch (e) {
      return NativeCompressionResult(
        NativeCompressionStatus.errorUnknown,
        'Failed to communicate with native code: ${e.message}',
      );
    }
  }
}
