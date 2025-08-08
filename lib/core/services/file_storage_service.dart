import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileStorageService {
  static const String _privateSubdirectory = 'aegis_wallet';

  Future<Directory> _getBaseWalletDirectory() async {
    final appDocsDir = await getApplicationDocumentsDirectory();
    final walletDir = Directory(p.join(appDocsDir.path, _privateSubdirectory));
    if (!await walletDir.exists()) {
      await walletDir.create(recursive: true);
    }
    return walletDir;
  }

  Future<Directory> _getPrivateDirectory({String? folderPath}) async {
    final baseDir = await _getBaseWalletDirectory();
    if (folderPath == null || folderPath.isEmpty) {
      return baseDir;
    }
    final targetDir = Directory(p.join(baseDir.path, folderPath));
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    return targetDir;
  }

  Future<String> saveToPrivateDirectory({
    required String fileName,
    required Uint8List data,
    String? folderPath,
  }) async {
    final directory = await _getPrivateDirectory(folderPath: folderPath);
    final filePath = p.join(directory.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(data, flush: true);
    debugPrint('Saved to private wallet: $filePath');
    return filePath;
  }

  Future<Uint8List?> loadFromPrivateDirectory({
    required String fileName,
    String? folderPath,
  }) async {
    try {
      final directory = await _getPrivateDirectory(folderPath: folderPath);
      final filePath = p.join(directory.path, fileName);
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (e) {
      debugPrint('Error loading from private storage: $e');
    }
    return null;
  }

  Future<void> deleteFromPrivateDirectory({
    required String fileName,
    String? folderPath,
  }) async {
    try {
      final directory = await _getPrivateDirectory(folderPath: folderPath);
      final filePath = p.join(directory.path, fileName);
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Deleted from private wallet: $filePath');
      }
    } catch (e) {
      debugPrint('Error deleting from private storage: $e');
    }
  }

  Future<List<FileSystemEntity>> listDirectoryContents({
    String? folderPath,
  }) async {
    final directory = await _getPrivateDirectory(folderPath: folderPath);
    if (await directory.exists()) {
      return directory.listSync();
    }
    return [];
  }

  Future<void> createFolder({
    required String folderName,
    String? parentFolderPath,
  }) async {
    final parentDir = await _getPrivateDirectory(folderPath: parentFolderPath);
    final newDir = Directory(p.join(parentDir.path, folderName));
    if (!await newDir.exists()) {
      await newDir.create();
      debugPrint('Created folder: ${newDir.path}');
    }
  }

  Future<void> deleteFolder({required String folderPath}) async {
    try {
      final directory = await _getPrivateDirectory(folderPath: folderPath);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        debugPrint('Deleted folder and all contents: ${directory.path}');
      }
    } catch (e) {
      debugPrint('Error deleting folder: $e');
    }
  }

  Future<String?> saveFile(Uint8List bytes, String fileName) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        final directory = await _getPrivateWalletDirectory();
        String filePath = p.join(directory.path, fileName);
        int count = 1;
        String baseName = p.basenameWithoutExtension(filePath);
        String extension = p.extension(filePath);
        while (await File(filePath).exists()) {
          filePath = p.join(directory.path, '$baseName ($count)$extension');
          count++;
        }
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        return filePath;
      } catch (e) {
        debugPrint('Error saving public file: $e');
        return null;
      }
    }
    return null;
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
        return getDownloadsDirectory();
      }
    }
    return getDownloadsDirectory();
  }

  Future<Directory> _getPrivateWalletDirectory() async {
    final appDocsDir = await getApplicationDocumentsDirectory();
    final walletDir = Directory(p.join(appDocsDir.path, _privateSubdirectory));
    if (!await walletDir.exists()) {
      await walletDir.create(recursive: true);
    }
    return walletDir;
  }

  Future<List<File>> listPrivateFiles() async {
    final directory = await _getPrivateWalletDirectory();
    if (await directory.exists()) {
      return directory.listSync().whereType<File>().toList();
    }
    return [];
  }
}
