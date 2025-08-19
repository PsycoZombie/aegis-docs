import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileStorageService {
  static const String _privateSubdirectory = 'aegis_wallet';
  static const String _publicSubdirectory = 'AegisDocs';

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

  Future<void> renameFile({
    required String oldName,
    required String newName,
    String? folderPath,
  }) async {
    final directory = await _getPrivateDirectory(folderPath: folderPath);
    final oldPath = p.join(directory.path, oldName);
    final newPath = p.join(directory.path, newName);
    final file = File(oldPath);
    if (await file.exists()) {
      await file.rename(newPath);
      debugPrint('Renamed file to: $newPath');
    }
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

  Future<List<String>> listAllFoldersRecursively() async {
    final baseDir = await _getBaseWalletDirectory();
    final allFolders = <String>[];

    void search(Directory dir) {
      try {
        final entities = dir.listSync();
        for (final entity in entities) {
          if (entity is Directory) {
            final relativePath = p.relative(entity.path, from: baseDir.path);
            allFolders.add(relativePath);
            search(entity);
          }
        }
      } catch (e) {
        debugPrint('Could not list directory ${dir.path}: $e');
      }
    }

    search(baseDir);
    allFolders.sort();
    return allFolders;
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

  Future<String?> saveToPublicDirectory({
    required String fileName,
    required Uint8List data,
  }) async {
    final directory = await getPublicExportDirectory();
    if (directory == null) return null;

    try {
      final filePath = p.join(directory.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(data);
      debugPrint('File exported to public directory: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error saving to public directory: $e');
      return null;
    }
  }

  Future<void> renameFolder({
    required String oldPath,
    required String newName,
  }) async {
    final baseDir = await _getBaseWalletDirectory();
    final oldFullPath = p.join(baseDir.path, oldPath);
    final parentPath = p.dirname(oldFullPath);
    final newFullPath = p.join(parentPath, newName);
    final directory = Directory(oldFullPath);
    if (await directory.exists()) {
      await directory.rename(newFullPath);
      debugPrint('Renamed folder to: $newFullPath');
    }
  }

  Future<Directory?> getPublicExportDirectory() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        debugPrint('Storage permission denied.');
        return null;
      }
    }

    Directory? downloadsDir = await getDownloadsDirectory();

    if (downloadsDir == null) {
      debugPrint('Could not get downloads directory.');
      return null;
    }

    final exportDir = Directory(p.join(downloadsDir.path, _publicSubdirectory));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }
}
