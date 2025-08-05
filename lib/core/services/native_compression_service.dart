import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class NativeCompressionService {
  static const _platform = MethodChannel('com.aegis_docs.compress');

  Future<String> compressPdf({
    required String filePath,
    required int sizeLimit,
    required bool preserveText,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFileName = 'temp_compressed_${const Uuid().v4()}.pdf';
      final outputPath = '${tempDir.path}/$tempFileName';

      final String? resultPath = await _platform.invokeMethod('compressPdf', {
        'filePath': filePath,
        'outputPath': outputPath,
        'sizeLimit': sizeLimit,
        'preserveText': preserveText ? 1 : 0,
      });

      if (resultPath == null || resultPath.isEmpty) {
        throw Exception('Native compression returned an empty or null path.');
      }

      return resultPath;
    } on PlatformException catch (e) {
      throw Exception("Failed to compress PDF via native code: ${e.message}");
    }
  }

  Future<String> compressImage({
    required String filePath,
    required int sizeLimit,
  }) async {
    try {
      final String? resultPath = await _platform.invokeMethod('compressImage', {
        'filePath': filePath,
        'sizeLimit': sizeLimit,
      });

      if (resultPath == null || resultPath.isEmpty) {
        throw Exception('Native compression returned an empty or null path.');
      }
      return resultPath;
    } on PlatformException catch (e) {
      throw Exception("Failed to compress image via native code: ${e.message}");
    }
  }
}
