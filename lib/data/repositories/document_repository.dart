import 'dart:convert';
import 'dart:io';

import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/core/media_processing/file_picker_service.dart';
import 'package:aegis_docs/core/media_processing/image_processor.dart';
import 'package:aegis_docs/core/media_processing/pdf_processor.dart';
import 'package:aegis_docs/core/services/cloud_storage_service.dart';
import 'package:aegis_docs/core/services/encryption_service.dart';
import 'package:aegis_docs/core/services/file_storage_service.dart';
import 'package:aegis_docs/core/services/native_pdf_compression_service.dart';
import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

/// Provides the single instance of [DocumentRepository]
/// after all its dependencies,
/// including the asynchronously initialized [EncryptionService], are ready.
final documentRepositoryProvider = FutureProvider<DocumentRepository>((
  ref,
) async {
  // Asynchronously wait for the encryption service to initialize.
  final encryptionService = ref.watch(encryptionServiceProvider);

  return DocumentRepository(
    filePickerService: ref.watch(filePickerServiceProvider),
    imageProcessor: ref.watch(imageProcessorProvider),
    pdfProcessor: ref.watch(pdfProcessorProvider),
    nativePdfCompressionService: ref.watch(nativePdfCompressionServiceProvider),
    fileStorageService: ref.watch(fileStorageServiceProvider),
    encryptionService: encryptionService,
    cloudStorageService: ref.watch(cloudStorageServiceProvider),
  );
});

// --- Isolate Payloads and Entry Points for Backup/Restore --- //

/// A payload for passing backup parameters to a separate isolate.
class _BackupPayload {
  _BackupPayload(this.walletPath, this.keyJson);
  final String walletPath;
  final String keyJson;
}

/// A payload for passing restore parameters to a separate isolate.
class _RestorePayload {
  _RestorePayload(this.zipBytes, this.walletPath);
  final Uint8List zipBytes;
  final String walletPath;
}

/// Isolate entry point to create a zip archive of the wallet.
Uint8List _createBackupIsolate(_BackupPayload payload) {
  final archive = Archive()
    ..addFile(
      ArchiveFile(
        AppConstants.backupKeyFileName,
        payload.keyJson.length,
        utf8.encode(payload.keyJson),
      ),
    );

  final walletDir = Directory(payload.walletPath);
  // Using sync methods is efficient and safe inside an isolate.
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

/// Isolate entry point to restore a wallet from a zip archive.
void _restoreBackupIsolate(_RestorePayload payload) {
  final archive = ZipDecoder().decodeBytes(payload.zipBytes);
  final walletDir = Directory(payload.walletPath);

  if (walletDir.existsSync()) {
    walletDir.deleteSync(recursive: true);
  }
  walletDir.createSync(recursive: true);

  for (final file in archive) {
    if (file.isFile && file.name != AppConstants.backupKeyFileName) {
      final filePath = p.join(walletDir.path, file.name);
      final outFile = File(filePath);
      outFile.parent.createSync(recursive: true);
      outFile.writeAsBytesSync(file.content as List<int>);
    }
  }
}

/// A repository that acts as a facade for all document and
/// media-related operations.
///
/// This is the primary entry point for the UI/ViewModel layer to interact with the
/// app's backend services. It orchestrates all services to provide cohesive
/// business logic.
class DocumentRepository {
  /// Creates an instance of the DocumentRepository.
  DocumentRepository({
    required FilePickerService filePickerService,
    required ImageProcessor imageProcessor,
    required PdfProcessor pdfProcessor,
    required NativePdfCompressionService nativePdfCompressionService,
    required FileStorageService fileStorageService,
    required EncryptionService encryptionService,
    required CloudStorageService cloudStorageService,
  }) : _filePickerService = filePickerService,
       _imageProcessor = imageProcessor,
       _pdfProcessor = pdfProcessor,
       _nativePdfCompressionService = nativePdfCompressionService,
       _fileStorageService = fileStorageService,
       _encryptionService = encryptionService,
       _cloudStorageService = cloudStorageService;

  final FilePickerService _filePickerService;
  final ImageProcessor _imageProcessor;
  final PdfProcessor _pdfProcessor;
  final NativePdfCompressionService _nativePdfCompressionService;
  final FileStorageService _fileStorageService;
  final EncryptionService _encryptionService;
  final CloudStorageService _cloudStorageService;

  // --- Wallet & File System --- //

  /// Recursively lists all subfolder paths within the private wallet.
  Future<List<String>> listAllFolders() =>
      _fileStorageService.listAllFoldersRecursively();

  /// Lists all files and folders within a
  /// specific directory in the private wallet.
  Future<List<FileSystemEntity>> listWalletContents({String? folderPath}) =>
      _fileStorageService.listDirectoryContents(folderPath: folderPath);

  /// Lists all encrypted files (non-recursively) in
  /// the root of the private wallet.
  Future<List<File>> listEncryptedFiles() async {
    return _fileStorageService.listPrivateFiles();
  }

  /// Creates a new folder in the wallet.
  Future<void> createFolderInWallet({
    required String folderName,
    String? parentFolderPath,
  }) => _fileStorageService.createFolder(
    folderName: folderName,
    parentFolderPath: parentFolderPath,
  );

  /// Deletes a folder and all its contents from the wallet.
  Future<void> deleteFolderFromWallet({required String folderPath}) =>
      _fileStorageService.deleteFolder(folderPath: folderPath);

  /// Renames a file within the wallet.
  Future<void> renameFileInWallet({
    required String oldName,
    required String newName,
    String? folderPath,
  }) => _fileStorageService.renameFile(
    oldName: oldName,
    newName: newName,
    folderPath: folderPath,
  );

  /// Renames a folder within the wallet.
  Future<void> renameFolderInWallet({
    required String oldPath,
    required String newName,
  }) => _fileStorageService.renameFolder(oldPath: oldPath, newName: newName);

  // --- Document Encryption & Management --- //

  /// Encrypts and saves data as a new document in the wallet.
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

  /// Loads and decrypts a document from the wallet.
  Future<Uint8List?> loadDecryptedDocument({
    required String fileName,
    String? folderPath,
  }) async {
    final encryptedDataBytes = await _fileStorageService
        .loadFromPrivateDirectory(fileName: fileName, folderPath: folderPath);
    if (encryptedDataBytes == null) return null;
    return _encryptionService.decrypt(encryptedDataBytes);
  }

  /// Deletes a document from the wallet.
  Future<void> deleteEncryptedDocument({
    required String fileName,
    String? folderPath,
  }) async {
    await _fileStorageService.deleteFromPrivateDirectory(
      fileName: fileName,
      folderPath: folderPath,
    );
  }

  // --- Public File Operations (Import/Export) --- //

  /// Picks a single image from the device.
  Future<ProcessedFileResult> pickImage() => _filePickerService.pickImage();

  /// Picks a single PDF from the device.
  Future<PickedFileModel?> pickPdf() => _filePickerService.pickPdf();

  /// Picks multiple images from the device.
  Future<List<ProcessedFileResult>> pickMultipleImages() =>
      _filePickerService.pickMultipleImages();

  /// Picks and sanitizes multiple images, preparing them for PDF conversion.
  Future<List<PickedFileModel>> pickAndSanitizeMultipleImagesForPdf() =>
      _filePickerService.pickAndSanitizeMultipleImagesForPdf();

  /// Saves a document to a public directory, handling name conflicts.
  Future<String?> saveDocument(Uint8List bytes, {required String fileName}) =>
      _fileStorageService.saveFile(bytes, fileName);

  /// Decrypts a document and saves it to the public "Downloads" folder.
  Future<Uint8List?> exportDecryptedDocument({
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

    await _fileStorageService.saveToPublicDownloads(
      fileName: fileName,
      data: decryptedBytes,
    );
    return decryptedBytes;
  }

  // --- Image Processing --- //

  /// Resizes an image to the specified dimensions.
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

  /// Compresses an image with the given quality.
  Future<Uint8List> compressImage(Uint8List imageBytes, {int quality = 85}) =>
      _imageProcessor.compressImage(imageBytes: imageBytes, quality: quality);

  /// Opens an interactive image cropping UI.
  Future<Uint8List?> cropImage(
    Uint8List imageBytes, {
    required ThemeData theme,
  }) => _imageProcessor.crop(imageBytes: imageBytes, theme: theme);

  /// Changes the format of an image (e.g., PNG to JPG).
  Future<Uint8List> changeImageFormat(
    Uint8List imageBytes, {
    required String originalFormat,
    required String targetFormat,
  }) => _imageProcessor.changeFormat(
    imageBytes: imageBytes,
    originalFormat: originalFormat,
    targetFormat: targetFormat,
  );

  // --- PDF Processing --- //

  /// Converts a single image to a single-page PDF.
  Future<Uint8List> convertImageToPdf(Uint8List imageBytes) =>
      _pdfProcessor.convertImageToPdf(imageBytes: imageBytes);

  /// Converts a list of images to a multi-page PDF.
  Future<Uint8List> convertImagesToPdf(List<Uint8List> imageBytesList) =>
      _pdfProcessor.convertImagesToPdf(imageBytesList: imageBytesList);

  /// Converts all pages of a PDF into a list of images.
  Future<List<Uint8List>> convertPdfToImages(Uint8List pdfBytes) =>
      _pdfProcessor.convertPdfToImages(pdfBytes: pdfBytes);

  /// Checks if a PDF document is password-protected.
  Future<bool> isPdfEncrypted(Uint8List pdfBytes) =>
      _pdfProcessor.isPdfEncrypted(pdfBytes: pdfBytes);

  /// Applies password protection to a PDF document.
  Future<Uint8List> lockPdf(Uint8List pdfBytes, {required String password}) =>
      _pdfProcessor.lockPdf(pdfBytes: pdfBytes, password: password);

  /// Removes password protection from a PDF document.
  Future<Uint8List> unlockPdf(Uint8List pdfBytes, {required String password}) =>
      _pdfProcessor.unlockPdf(pdfBytes: pdfBytes, password: password);

  /// Changes the password of a password-protected PDF document.
  Future<Uint8List> changePdfPassword(
    Uint8List pdfBytes, {
    required String oldPassword,
    required String newPassword,
  }) => _pdfProcessor.changePdfPassword(
    pdfBytes: pdfBytes,
    oldPassword: oldPassword,
    newPassword: newPassword,
  );

  // --- Native Compression --- //

  /// Compresses a PDF using the high-performance native MuPDF implementation.
  Future<String?> compressPdfWithNative({
    required String filePath,
    required int sizeLimit,
    required bool preserveText,
  }) async {
    return _nativePdfCompressionService.compressPdf(
      filePath: filePath,
      sizeLimit: sizeLimit,
      preserveText: preserveText,
    );
  }

  // --- Cloud Backup & Restore --- //

  /// Deletes the wallet backup from Google Drive.
  Future<void> deleteBackupFromDrive() async {
    await _cloudStorageService.deleteBackup(AppConstants.backupFileName);
  }

  /// Downloads the wallet backup from Google Drive.
  Future<Uint8List?> downloadBackupFromDrive() async {
    return _cloudStorageService.downloadBackup(AppConstants.backupFileName);
  }

  /// Creates a complete, encrypted backup of the wallet
  /// and uploads it to Google Drive.
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
      AppConstants.backupFileName,
    );
  }

  /// Restores the wallet from a downloaded backup.
  Future<void> restoreWalletFromBackupData({
    required Uint8List backupBytes,
    required String masterPassword,
  }) async {
    final archive = ZipDecoder().decodeBytes(backupBytes);
    final keyFile = archive.findFile(AppConstants.backupKeyFileName);
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
