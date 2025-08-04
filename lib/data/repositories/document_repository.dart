import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/media_processing/file_picker_service.dart';
import '../../core/media_processing/image_processor.dart';
import '../../core/media_processing/pdf_processor.dart';
import '../../core/services/encryption_service.dart';
import '../../core/services/file_storage_service.dart';
import '../../core/services/native_compression_service.dart';
import '../models/picked_file_model.dart';

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
  }) => _imageProcessor.resize(
    imageBytes: imageBytes,
    width: width,
    height: height,
  );
  Future<Uint8List> compressImage(Uint8List imageBytes, {int quality = 85}) =>
      _imageProcessor.compressImage(imageBytes: imageBytes, quality: quality);
  Future<Uint8List?> cropImage(
    Uint8List imageBytes, {
    required ThemeData theme,
  }) => _imageProcessor.crop(imageBytes: imageBytes, theme: theme);
  Future<Uint8List> changeImageFormat(
    Uint8List imageBytes, {
    required String format,
  }) => _imageProcessor.changeFormat(imageBytes: imageBytes, format: format);
  Future<Uint8List> convertImageToPdf(Uint8List imageBytes) =>
      _pdfProcessor.convertImageToPdf(imageBytes: imageBytes);
  Future<List<Uint8List>> convertPdfToImages(Uint8List pdfBytes) =>
      _pdfProcessor.convertPdfToImages(pdfBytes: pdfBytes);
  Future<String?> compressPdfWithNative({
    required int sizeLimit,
    required bool preserveText,
  }) async {
    final pickedPdf = await _filePickerService.pickPdf();
    if (pickedPdf?.path == null) return null;
    return _nativeCompressionService.compressPdf(
      filePath: pickedPdf!.path!,
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
    final encryptedDataBytes = _encryptionService.encrypt(data);

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
}
