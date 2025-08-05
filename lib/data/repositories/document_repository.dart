import 'dart:io';
import 'dart:typed_data';

import 'package:aegis_docs/core/media_processing/file_picker_service.dart';
import 'package:aegis_docs/core/media_processing/image_processor.dart';
import 'package:aegis_docs/core/media_processing/pdf_processor.dart';
import 'package:aegis_docs/core/services/encryption_service.dart';
import 'package:aegis_docs/core/services/file_storage_service.dart';
import 'package:aegis_docs/core/services/native_compression_service.dart';
import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:flutter/material.dart';

class DocumentRepository {
  final FilePickerService _filePickerService;
  final ImageProcessor _imageProcessor;
  final PdfProcessor _pdfProcessor;
  final NativeCompressionService _nativeCompressionService;
  final FileStorageService _fileStorageService;
  final EncryptionService _encryptionService;

  DocumentRepository({
    required FilePickerService filePickerService,
    required ImageProcessor imageProcessor,
    required PdfProcessor pdfProcessor,
    required NativeCompressionService nativeCompressionService,
    required FileStorageService fileStorageService,
    required EncryptionService encryptionService,
  }) : _filePickerService = filePickerService,
       _imageProcessor = imageProcessor,
       _pdfProcessor = pdfProcessor,
       _nativeCompressionService = nativeCompressionService,
       _fileStorageService = fileStorageService,
       _encryptionService = encryptionService;

  Future<PickedFile?> pickImage() => _filePickerService.pickImage();
  Future<PickedFile?> pickPdf() => _filePickerService.pickPdf();
  Future<List<PickedFile>> pickMultipleImages() =>
      _filePickerService.pickMultipleImages();
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
    // The file picking logic has been removed.
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

  Future<void> saveEncryptedDocument({
    required String fileName,
    required Uint8List data,
  }) async {
    final encryptedDataBytes = await _encryptionService.encrypt(data);

    await _fileStorageService.saveToPrivateDirectory(
      fileName: fileName,
      data: encryptedDataBytes,
    );
  }

  Future<Uint8List?> loadDecryptedDocument(String fileName) async {
    final encryptedDataBytes = await _fileStorageService
        .loadFromPrivateDirectory(fileName);
    if (encryptedDataBytes == null) return null;

    return _encryptionService.decrypt(encryptedDataBytes);
  }

  Future<void> deleteEncryptedDocument(String fileName) async {
    await _fileStorageService.deleteFromPrivateDirectory(fileName);
  }

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
}
