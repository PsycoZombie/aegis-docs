import 'package:aegis_docs/core/media_processing/file_picker_service.dart';
import 'package:aegis_docs/core/media_processing/image_processor.dart';
import 'package:aegis_docs/core/media_processing/pdf_processor.dart';
import 'package:aegis_docs/core/services/encryption_service.dart';
import 'package:aegis_docs/core/services/file_storage_service.dart';
import 'package:aegis_docs/core/services/native_compression_service.dart';
import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'document_providers.g.dart';

@Riverpod(keepAlive: true)
FilePickerService filePickerService(Ref ref) {
  return FilePickerService();
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

@Riverpod(keepAlive: true)
class EncryptionServiceController extends _$EncryptionServiceController {
  @override
  Future<EncryptionService> build() async {
    final service = EncryptionService();
    await service.init();
    return service;
  }
}

@Riverpod(keepAlive: true)
Future<DocumentRepository> documentRepository(Ref ref) async {
  final filePicker = ref.watch(filePickerServiceProvider);
  final imageProcessor = ref.watch(imageProcessorProvider);
  final pdfProcessor = ref.watch(pdfProcessorProvider);
  final nativeCompression = ref.watch(nativeCompressionServiceProvider);
  final fileStorage = ref.watch(fileStorageServiceProvider);
  final encryption = await ref.watch(
    encryptionServiceControllerProvider.future,
  );

  return DocumentRepository(
    filePickerService: filePicker,
    imageProcessor: imageProcessor,
    pdfProcessor: pdfProcessor,
    nativeCompressionService: nativeCompression,
    fileStorageService: fileStorage,
    encryptionService: encryption,
  );
}
