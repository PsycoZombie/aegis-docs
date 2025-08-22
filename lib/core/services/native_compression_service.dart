import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class NativeCompressionService {
  static const _platform = MethodChannel('com.aegis_docs.compress');

  Future<void> cleanupExportedFiles({required int expirationInMinutes}) async {
    try {
      await _platform.invokeMethod('cleanupExportedFiles', {
        'expirationInMinutes': expirationInMinutes,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to run native cleanup: ${e.message}');
    }
  }

  Future<String> saveToDownloads({
    required String fileName,
    required Uint8List data,
  }) async {
    try {
      final result = await _platform.invokeMethod(
        'saveToDownloads',
        {'fileName': fileName, 'data': data},
      );

      final resultPath = result.toString();

      if (resultPath.isEmpty || resultPath.startsWith('Error:')) {
        throw Exception(
          resultPath == ''
              ? resultPath
              : 'Native save returned an empty or null path.',
        );
      }
      return resultPath;
    } on PlatformException catch (e) {
      throw Exception('Failed to save file via native code: ${e.message}');
    }
  }

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
        'preserveText': preserveText ? 1 : 0,
      });

      final resultPath = result.toString();

      if (resultPath == '' || resultPath.isEmpty) {
        throw Exception('Native compression returned an empty or null path.');
      }

      return resultPath;
    } on PlatformException catch (e) {
      throw Exception('Failed to compress PDF via native code: ${e.message}');
    }
  }

  Future<String> compressImage({
    required String filePath,
    required int sizeLimit,
  }) async {
    try {
      final result = await _platform.invokeMethod('compressImage', {
        'filePath': filePath,
        'sizeLimit': sizeLimit,
      });

      final resultPath = result.toString();

      if (resultPath == '' || resultPath.isEmpty) {
        throw Exception('Native compression returned an empty or null path.');
      }
      return resultPath;
    } on PlatformException catch (e) {
      throw Exception('Failed to compress image via native code: ${e.message}');
    }
  }
}
