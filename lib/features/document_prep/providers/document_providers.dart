import 'package:aegis_docs/core/services/file_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/media_processing/file_picker_service.dart';
import '../../../core/media_processing/image_processor.dart';
import '../../../core/media_processing/pdf_processor.dart';
import '../../../core/services/native_compression_service.dart';
import '../../../data/repositories/document_repository.dart';

part 'document_providers.g.dart';

@Riverpod(keepAlive: true)
FilePickerService filePickerService(Ref ref) {
  return FilePickerService();
}

@Riverpod(keepAlive: true)
DocumentRepository documentRepository(Ref ref) {
  final filePicker = ref.watch(filePickerServiceProvider);
  final fileStorage = ref.watch(fileStorageServiceProvider);
  final imageProcessor = ref.watch(imageProcessorProvider);
  final nativeCompression = ref.watch(nativeCompressionServiceProvider);
  final pdfProcessor = ref.watch(pdfProcessorProvider);

  return DocumentRepository(
    fileStorageService: fileStorage,
    filePickerService: filePicker,
    imageProcessor: imageProcessor,
    pdfProcessor: pdfProcessor,
    nativeCompressionService: nativeCompression,
  );
}

@Riverpod(keepAlive: true)
FileStorageService fileStorageService(Ref ref) {
  return FileStorageService();
}

@Riverpod(keepAlive: true)
ImageProcessor imageProcessor(Ref ref) {
  return ImageProcessor();
}

@Riverpod(keepAlive: true)
PdfProcessor pdfProcessor(Ref ref) {
  return PdfProcessor();
}

@Riverpod(keepAlive: true)
NativeCompressionService nativeCompressionService(Ref ref) {
  return NativeCompressionService();
}
