import 'dart:typed_data';

import 'package:aegis_docs/core/services/file_storage_service.dart';

import '../../core/media_processing/file_picker_service.dart';
import '../../core/media_processing/image_processor.dart';
import '../../core/media_processing/pdf_processor.dart';
import '../../core/services/native_compression_service.dart';
import '../models/picked_file_model.dart';

class DocumentRepository {
  final FilePickerService _filePickerService;
  final ImageProcessor _imageProcessor;
  final PdfProcessor _pdfProcessor;
  final NativeCompressionService _nativeCompressionService;
  final FileStorageService _fileStorageService;

  DocumentRepository({
    required FilePickerService filePickerService,
    required ImageProcessor imageProcessor,
    required PdfProcessor pdfProcessor,
    required NativeCompressionService nativeCompressionService,
    required FileStorageService fileStorageService,
  }) : _filePickerService = filePickerService,
       _imageProcessor = imageProcessor,
       _pdfProcessor = pdfProcessor,
       _nativeCompressionService = nativeCompressionService,
       _fileStorageService = fileStorageService;

  Future<PickedFile?> pickImage() => _filePickerService.pickImage();

  Future<PickedFile?> pickPdf() => _filePickerService.pickPdf();

  Future<Uint8List> resizeImage(
    Uint8List imageBytes, {
    required int width,
    required int height,
  }) {
    return _imageProcessor.resize(
      imageBytes: imageBytes,
      width: width,
      height: height,
    );
  }

  Future<Uint8List> compressImage(Uint8List imageBytes, {int quality = 85}) {
    return _imageProcessor.compressImage(
      imageBytes: imageBytes,
      quality: quality,
    );
  }

  Future<Uint8List?> cropImage(Uint8List imageBytes) {
    return _imageProcessor.crop(imageBytes: imageBytes);
  }

  Future<Uint8List> changeImageFormat(
    Uint8List imageBytes, {
    required String format,
  }) {
    return _imageProcessor.changeFormat(imageBytes: imageBytes, format: format);
  }

  Future<Uint8List> convertImageToPdf(Uint8List imageBytes) {
    return _pdfProcessor.convertImageToPdf(imageBytes: imageBytes);
  }

  Future<List<Uint8List>> convertPdfToImages(Uint8List pdfBytes) {
    return _pdfProcessor.convertPdfToImages(pdfBytes: pdfBytes);
  }

  Future<String?> compressPdfWithNative({
    required int sizeLimit,
    required bool preserveText,
  }) async {
    final pickedPdf = await _filePickerService.pickPdf();

    if (pickedPdf?.path == null) {
      return null;
    }

    return _nativeCompressionService.compressPdf(
      filePath: pickedPdf!.path!,
      sizeLimit: sizeLimit,
      preserveText: preserveText,
    );
  }

  Future<String?> saveDocument(Uint8List bytes, {required String fileName}) {
    return _fileStorageService.saveFile(bytes, fileName);
  }
}
