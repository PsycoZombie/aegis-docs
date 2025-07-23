import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileStorageService {
  Future<String?> saveFile(Uint8List bytes, String fileName) async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      try {
        final directory = await _getPublicDownloadsDirectory();
        if (directory == null) {
          throw Exception(
            "Could not find or create the public Downloads directory.",
          );
        }

        String filePath = p.join(directory.path, fileName);
        debugPrint("Attempting to save to public path: $filePath");

        int count = 1;
        String baseName = p.basenameWithoutExtension(filePath);
        String extension = p.extension(filePath);
        while (await File(filePath).exists()) {
          filePath = p.join(directory.path, '$baseName ($count)$extension');
          count++;
        }

        final file = File(filePath);
        await file.writeAsBytes(bytes);
        debugPrint("File successfully saved to public path: $filePath");

        return filePath;
      } catch (e) {
        debugPrint('Error saving file: $e');
        return null;
      }
    } else {
      debugPrint('Storage permission was denied.');
      return null;
    }
  }

  Future<Directory?> _getPublicDownloadsDirectory() async {
    if (Platform.isAndroid) {
      try {
        const String downloadsPathString = '/storage/emulated/0/Download';
        final Directory publicDownloadsDir = Directory(downloadsPathString);

        if (!await publicDownloadsDir.exists()) {
          await publicDownloadsDir.create(recursive: true);
        }

        return publicDownloadsDir;
      } catch (e) {
        debugPrint(
          "Error accessing public downloads directory: $e. Falling back.",
        );
        try {
          return await getDownloadsDirectory();
        } catch (e2) {
          debugPrint("path_provider's getDownloadsDirectory also failed: $e2");
          return null;
        }
      }
    } else {
      return await getDownloadsDirectory();
    }
  }
}
