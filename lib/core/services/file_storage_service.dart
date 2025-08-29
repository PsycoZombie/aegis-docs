import 'dart:io';

import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Provides an instance of [FileStorageService] for dependency injection.
final fileStorageServiceProvider = Provider<FileStorageService>((ref) {
  return FileStorageService();
});

/// A service for managing all file system interactions for the application.
class FileStorageService {
  static const String _privateSubdirectory =
      AppConstants.privateWalletDirectory;
  static const String _publicSubdirectory = AppConstants.publicExportDirectory;

  /// The method channel used to communicate with the native platform.
  static const _platform = MethodChannel(AppConstants.platformChannelName);

  /// Returns the root directory for the app's private wallet storage.
  /// Creates the directory if it doesn't exist.
  Future<Directory> getBaseWalletDirectory() async {
    final appDocsDir = await getApplicationDocumentsDirectory();
    final walletDir = Directory(p.join(appDocsDir.path, _privateSubdirectory));
    if (!await walletDir.exists()) {
      await walletDir.create(recursive: true);
    }
    return walletDir;
  }

  /// Returns a specific directory within the private wallet.
  /// If [folderPath] is null or empty, returns the base wallet directory.
  Future<Directory> _getPrivateDirectory({String? folderPath}) async {
    final baseDir = await getBaseWalletDirectory();
    if (folderPath == null || folderPath.isEmpty) {
      return baseDir;
    }
    final targetDir = Directory(p.join(baseDir.path, folderPath));
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    return targetDir;
  }

  /// Saves a file to the internal private wallet.
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

  /// Loads a file from the internal private wallet.
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
    } on Object catch (e) {
      debugPrint('Error loading from private storage: $e');
    }
    return null;
  }

  /// Deletes a file from the internal private wallet.
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
    } on Object catch (e) {
      debugPrint('Error deleting from private storage: $e');
    }
  }

  /// Lists all files and folders within a specific directory in
  /// the private wallet (non-recursive).
  Future<List<FileSystemEntity>> listDirectoryContents({
    String? folderPath,
  }) async {
    final directory = await _getPrivateDirectory(folderPath: folderPath);
    if (await directory.exists()) {
      // Use asynchronous listing to avoid blocking the UI.
      return directory.list().toList();
    }
    return [];
  }

  /// Renames a file within a specific folder in the private wallet.
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

  /// Creates a new folder within the private wallet.
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

  /// Deletes a folder and all its contents from the private wallet.
  Future<void> deleteFolder({required String folderPath}) async {
    try {
      final directory = await _getPrivateDirectory(folderPath: folderPath);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        debugPrint('Deleted folder and all contents: ${directory.path}');
      }
    } on Object catch (e) {
      debugPrint('Error deleting folder: $e');
    }
  }

  /// Saves a file, handling filename conflicts by appending a number.
  /// NOTE: This method saves to the internal private
  /// wallet directory, not a public one.
  Future<String?> saveFile(Uint8List bytes, String fileName) async {
    // Note: Permission.storage is not required for
    // the app's internal directory.
    // This check may be redundant or intended for a
    //different (public) save location.
    final status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        final directory = await getBaseWalletDirectory();
        var filePath = p.join(directory.path, fileName);
        var count = 1;
        final baseName = p.basenameWithoutExtension(filePath);
        final extension = p.extension(filePath);
        while (await File(filePath).exists()) {
          filePath = p.join(directory.path, '$baseName ($count)$extension');
          count++;
        }
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        return filePath;
      } on Object catch (e) {
        debugPrint('Error saving public file: $e');
        return null;
      }
    }
    return null;
  }

  /// Recursively lists all subfolder paths within the private wallet.
  Future<List<String>> listAllFoldersRecursively() async {
    final baseDir = await getBaseWalletDirectory();
    final allFolders = <String>[];
    final dirQueue = <Directory>[baseDir];

    while (dirQueue.isNotEmpty) {
      final currentDir = dirQueue.removeAt(0);
      try {
        // Asynchronously iterate through the directory contents.
        await for (final entity in currentDir.list()) {
          if (entity is Directory) {
            final relativePath = p.relative(entity.path, from: baseDir.path);
            allFolders.add(relativePath);
            dirQueue.add(entity);
          }
        }
      } on Object catch (e) {
        debugPrint('Could not list directory ${currentDir.path}: $e');
      }
    }
    allFolders.sort();
    return allFolders;
  }

  /// Lists all files (non-recursively) in the root of the private wallet.
  Future<List<File>> listPrivateFiles() async {
    final directory = await getBaseWalletDirectory();
    if (await directory.exists()) {
      final entities = await directory.list().toList();
      return entities.whereType<File>().toList();
    }
    return [];
  }

  /// Saves a file to the public "AegisDocs" directory.
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
    } on Object catch (e) {
      debugPrint('Error saving to public directory: $e');
      return null;
    }
  }

  /// Invokes a native method to save a file to
  /// the device's public "Downloads" directory.
  ///
  /// Using a native implementation can be more
  /// reliable across different Android versions.
  /// Throws an [Exception] if the native call fails or returns an error.
  /// Returns the full path of the saved file.
  Future<String> saveToPublicDownloads({
    required String fileName,
    required Uint8List data,
  }) async {
    try {
      final result = await _platform.invokeMethod(
        AppConstants.methodSaveToDownloads,
        {AppConstants.paramFileName: fileName, AppConstants.paramData: data},
      );

      final resultPath = result as String?;

      if (resultPath == null ||
          resultPath.isEmpty ||
          resultPath.startsWith('Error:')) {
        throw Exception(
          resultPath != null && resultPath.startsWith('Error:')
              ? resultPath
              : 'Native save returned an empty or null path.',
        );
      }
      return resultPath;
    } on PlatformException catch (e) {
      throw Exception('Failed to save file via native code: ${e.message}');
    }
  }

  /// Renames a folder within the private wallet.
  Future<void> renameFolder({
    required String oldPath,
    required String newName,
  }) async {
    final baseDir = await getBaseWalletDirectory();
    final oldFullPath = p.join(baseDir.path, oldPath);
    final parentPath = p.dirname(oldFullPath);
    final newFullPath = p.join(parentPath, newName);
    final directory = Directory(oldFullPath);
    if (await directory.exists()) {
      await directory.rename(newFullPath);
      debugPrint('Renamed folder to: $newFullPath');
    }
  }

  /// Gets the public "AegisDocs" directory, creating it if it doesn't exist.
  Future<Directory?> getPublicExportDirectory() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        debugPrint('Storage permission denied.');
        return null;
      }
    }

    final downloadsDir = await getDownloadsDirectory();

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
