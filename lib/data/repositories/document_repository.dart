import 'dart:convert';
import 'dart:io';

import 'package:aegis_docs/core/media_processing/file_picker_service.dart';
import 'package:aegis_docs/core/media_processing/image_processor.dart';
import 'package:aegis_docs/core/media_processing/pdf_processor.dart';
import 'package:aegis_docs/core/services/cloud_storage_service.dart';
import 'package:aegis_docs/core/services/encryption_service.dart';
import 'package:aegis_docs/core/services/file_storage_service.dart';
import 'package:aegis_docs/core/services/native_compression_service.dart';
import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class _BackupPayload {
  _BackupPayload(this.walletPath, this.keyJson);
  final String walletPath;
  final String keyJson;
}

class _RestorePayload {
  _RestorePayload(this.zipBytes, this.walletPath);
  final Uint8List zipBytes;
  final String walletPath;
}

Uint8List _createBackupIsolate(_BackupPayload payload) {
  final archive = Archive()
    ..addFile(
      ArchiveFile(
        'aegis_key.json',
        payload.keyJson.length,
        utf8.encode(payload.keyJson),
      ),
    );

  final walletDir = Directory(payload.walletPath);
  final files = walletDir.listSync(recursive: true);
  for (final file in files) {
    if (file is File) {
      final relativePath = p.relative(file.path, from: walletDir.path);
      final fileBytes = file.readAsBytesSync();
      archive.addFile(ArchiveFile(relativePath, fileBytes.length, fileBytes));
    }
  }

  final zipEncoder = ZipEncoder();
  return Uint8List.fromList(zipEncoder.encode(archive));
}

void _restoreBackupIsolate(_RestorePayload payload) {
  final archive = ZipDecoder().decodeBytes(payload.zipBytes);
  final walletDir = Directory(payload.walletPath);

  if (walletDir.existsSync()) {
    walletDir.deleteSync(recursive: true);
  }
  walletDir.createSync(recursive: true);

  for (final file in archive) {
    if (file.isFile && file.name != 'aegis_key.json') {
      final filePath = p.join(walletDir.path, file.name);
      final outFile = File(filePath);
      outFile.parent.createSync(recursive: true);
      outFile.writeAsBytesSync(file.content as List<int>);
    }
  }
}

class DocumentRepository {
  DocumentRepository({
    required FilePickerService filePickerService,
    required ImageProcessor imageProcessor,
    required PdfProcessor pdfProcessor,
    required NativeCompressionService nativeCompressionService,
    required FileStorageService fileStorageService,
    required EncryptionService encryptionService,
    required CloudStorageService cloudStorageService,
  }) : _filePickerService = filePickerService,
       _imageProcessor = imageProcessor,
       _pdfProcessor = pdfProcessor,
       _nativeCompressionService = nativeCompressionService,
       _fileStorageService = fileStorageService,
       _encryptionService = encryptionService,
       _cloudStorageService = cloudStorageService;
  final FilePickerService _filePickerService;
  final ImageProcessor _imageProcessor;
  final PdfProcessor _pdfProcessor;
  final NativeCompressionService _nativeCompressionService;
  final FileStorageService _fileStorageService;
  final EncryptionService _encryptionService;
  final CloudStorageService _cloudStorageService;

  Future<List<String>> listAllFolders() =>
      _fileStorageService.listAllFoldersRecursively();

  Future<ProcessedFileResult> pickImage() => _filePickerService.pickImage();

  Future<PickedFile?> pickPdf() => _filePickerService.pickPdf();

  Future<List<ProcessedFileResult>> pickMultipleImages() =>
      _filePickerService.pickMultipleImages();

  Future<void> deleteBackupFromDrive() async {
    await _cloudStorageService.deleteBackup('aegis_wallet_backup.zip');
  }

  Future<List<int>?> exportDecryptedDocument({
    required String fileName,
    String? folderPath,
  }) async {
    final decryptedBytes = await loadDecryptedDocument(
      fileName: fileName,
      folderPath: folderPath,
    );

    if (decryptedBytes == null) {
      throw Exception('Failed to load or decrypt the document.');
    }

    await _nativeCompressionService.saveToDownloads(
      fileName: fileName,
      data: decryptedBytes,
    );
    return decryptedBytes;
  }

  Future<Uint8List> resizeImage(
    Uint8List imageBytes, {
    required int width,
    required int height,
    required String outputFormat,
  }) => _imageProcessor.resize(
    imageBytes: imageBytes,
    width: width,
    height: height,
    outputFormat: outputFormat,
  );

  Future<void> saveEncryptedDocument({
    required String fileName,
    required Uint8List data,
    String? folderPath,
  }) async {
    final encryptedDataBytes = await _encryptionService.encrypt(data);
    await _fileStorageService.saveToPrivateDirectory(
      fileName: fileName,
      data: encryptedDataBytes,
      folderPath: folderPath,
    );
  }

  Future<Uint8List?> loadDecryptedDocument({
    required String fileName,
    String? folderPath,
  }) async {
    final encryptedDataBytes = await _fileStorageService
        .loadFromPrivateDirectory(fileName: fileName, folderPath: folderPath);
    if (encryptedDataBytes == null) return null;
    return _encryptionService.decrypt(encryptedDataBytes);
  }

  Future<void> deleteEncryptedDocument({
    required String fileName,
    String? folderPath,
  }) async {
    await _fileStorageService.deleteFromPrivateDirectory(
      fileName: fileName,
      folderPath: folderPath,
    );
  }

  Future<List<FileSystemEntity>> listWalletContents({String? folderPath}) =>
      _fileStorageService.listDirectoryContents(folderPath: folderPath);

  Future<void> createFolderInWallet({
    required String folderName,
    String? parentFolderPath,
  }) => _fileStorageService.createFolder(
    folderName: folderName,
    parentFolderPath: parentFolderPath,
  );

  Future<void> deleteFolderFromWallet({required String folderPath}) =>
      _fileStorageService.deleteFolder(folderPath: folderPath);

  Future<Uint8List> compressImage(Uint8List imageBytes, {int quality = 85}) =>
      _imageProcessor.compressImage(imageBytes: imageBytes, quality: quality);

  Future<Uint8List?> cropImage(
    Uint8List imageBytes, {
    required ThemeData theme,
  }) => _imageProcessor.crop(imageBytes: imageBytes, theme: theme);

  Future<Uint8List> changeImageFormat(
    Uint8List imageBytes, {
    required String originalFormat,
    required String targetFormat,
  }) => _imageProcessor.changeFormat(
    imageBytes: imageBytes,
    originalFormat: originalFormat,
    targetFormat: targetFormat,
  );

  Future<Uint8List> convertImageToPdf(Uint8List imageBytes) =>
      _pdfProcessor.convertImageToPdf(imageBytes: imageBytes);

  Future<List<Uint8List>> convertPdfToImages(Uint8List pdfBytes) =>
      _pdfProcessor.convertPdfToImages(pdfBytes: pdfBytes);

  Future<String?> compressPdfWithNative({
    required String filePath,
    required int sizeLimit,
    required bool preserveText,
  }) async {
    return _nativeCompressionService.compressPdf(
      filePath: filePath,
      sizeLimit: sizeLimit,
      preserveText: preserveText,
    );
  }

  Future<Uint8List> convertImagesToPdf(List<Uint8List> imageBytesList) =>
      _pdfProcessor.convertImagesToPdf(imageBytesList: imageBytesList);

  Future<String?> saveDocument(Uint8List bytes, {required String fileName}) =>
      _fileStorageService.saveFile(bytes, fileName);

  Future<List<File>> listEncryptedFiles() async {
    return _fileStorageService.listPrivateFiles();
  }

  Future<bool> isPdfEncrypted(Uint8List pdfBytes) =>
      _pdfProcessor.isPdfEncrypted(pdfBytes: pdfBytes);

  Future<Uint8List> lockPdf(Uint8List pdfBytes, {required String password}) =>
      _pdfProcessor.lockPdf(pdfBytes: pdfBytes, password: password);

  Future<Uint8List> unlockPdf(Uint8List pdfBytes, {required String password}) =>
      _pdfProcessor.unlockPdf(pdfBytes: pdfBytes, password: password);

  Future<Uint8List> changePdfPassword(
    Uint8List pdfBytes, {
    required String oldPassword,
    required String newPassword,
  }) => _pdfProcessor.changePdfPassword(
    pdfBytes: pdfBytes,
    oldPassword: oldPassword,
    newPassword: newPassword,
  );

  Future<List<PickedFile>> pickAndSanitizeMultipleImagesForPdf() =>
      _filePickerService.pickAndSanitizeMultipleImagesForPdf();

  Future<void> renameFileInWallet({
    required String oldName,
    required String newName,
    String? folderPath,
  }) => _fileStorageService.renameFile(
    oldName: oldName,
    newName: newName,
    folderPath: folderPath,
  );

  Future<void> renameFolderInWallet({
    required String oldPath,
    required String newName,
  }) => _fileStorageService.renameFolder(oldPath: oldPath, newName: newName);

  Future<void> backupWalletToDrive(String masterPassword) async {
    final keyData = await _encryptionService.getEncryptedDataKeyForBackup(
      masterPassword,
    );
    final keyJson = jsonEncode(keyData);
    final walletDir = await _fileStorageService.getBaseWalletDirectory();

    final zipBytes = await compute(
      _createBackupIsolate,
      _BackupPayload(walletDir.path, keyJson),
    );

    await _cloudStorageService.uploadBackup(
      zipBytes,
      'aegis_wallet_backup.zip',
    );
  }

  Future<Uint8List?> downloadBackupFromDrive() async {
    return _cloudStorageService.downloadBackup('aegis_wallet_backup.zip');
  }

  Future<void> restoreWalletFromBackupData({
    required Uint8List backupBytes,
    required String masterPassword,
  }) async {
    final archive = ZipDecoder().decodeBytes(backupBytes);
    final keyFile = archive.findFile('aegis_key.json');
    if (keyFile == null) {
      throw Exception('Backup is corrupted: key file not found.');
    }

    final keyJson = utf8.decode(keyFile.content as List<int>);
    final keyData = jsonDecode(keyJson) as Map<String, dynamic>;
    await _encryptionService.restoreDataKeyFromBackup(masterPassword, keyData);

    final walletDir = await _fileStorageService.getBaseWalletDirectory();
    await compute(
      _restoreBackupIsolate,
      _RestorePayload(backupBytes, walletDir.path),
    );
  }
}
