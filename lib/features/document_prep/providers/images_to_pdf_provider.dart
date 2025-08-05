import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'document_providers.dart';

part 'images_to_pdf_provider.g.dart';

@immutable
class ImagesToPdfState {
  final List<PickedFile> selectedImages;
  final bool isProcessing;
  final String pdfFileName;

  const ImagesToPdfState({
    this.selectedImages = const [],
    this.isProcessing = false,
    this.pdfFileName = 'converted_document.pdf',
  });

  ImagesToPdfState copyWith({
    List<PickedFile>? selectedImages,
    bool? isProcessing,
    String? pdfFileName,
  }) {
    return ImagesToPdfState(
      selectedImages: selectedImages ?? this.selectedImages,
      isProcessing: isProcessing ?? this.isProcessing,
      pdfFileName: pdfFileName ?? this.pdfFileName,
    );
  }
}

@riverpod
class ImagesToPdfViewModel extends _$ImagesToPdfViewModel {
  @override
  Future<ImagesToPdfState> build() async {
    return const ImagesToPdfState();
  }

  Future<void> pickImages() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      final images = await repo.pickMultipleImages();
      return ImagesToPdfState(selectedImages: images);
    });
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (state.value == null) return;
    final images = List<PickedFile>.from(state.value!.selectedImages);
    final item = images.removeAt(oldIndex);
    images.insert(newIndex, item);
    state = AsyncData(state.value!.copyWith(selectedImages: images));
  }

  void removeImage(int index) {
    if (state.value == null) return;
    final images = List<PickedFile>.from(state.value!.selectedImages);
    images.removeAt(index);
    state = AsyncData(state.value!.copyWith(selectedImages: images));
  }

  void setPdfFileName(String name) {
    if (state.value == null) return;
    final finalName = name.endsWith('.pdf') ? name : '$name.pdf';
    state = AsyncData(state.value!.copyWith(pdfFileName: finalName));
  }

  Future<void> convertAndSavePdf() async {
    if (state.value == null || state.value!.selectedImages.isEmpty) {
      return;
    }

    state = AsyncData(state.value!.copyWith(isProcessing: true));

    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      final repo = await ref.read(documentRepositoryProvider.future);
      final imageBytesList = currentState.selectedImages
          .map((file) => file.bytes)
          .toList();

      final pdfBytes = await repo.convertImagesToPdf(imageBytesList);

      await repo.saveEncryptedDocument(
        fileName: currentState.pdfFileName,
        data: pdfBytes,
      );

      return currentState.copyWith(isProcessing: false);
    });
  }
}
