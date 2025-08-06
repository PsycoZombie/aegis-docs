import 'dart:async';
import 'dart:typed_data';

import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'document_providers.dart';

part 'images_to_pdf_provider.g.dart';

@immutable
class ImagesToPdfState {
  final List<PickedFile> selectedImages;
  final Uint8List? generatedPdf;
  final bool isProcessing;

  const ImagesToPdfState({
    this.selectedImages = const [],
    this.generatedPdf,
    this.isProcessing = false,
  });

  ImagesToPdfState copyWith({
    List<PickedFile>? selectedImages,
    ValueGetter<Uint8List?>? generatedPdf,
    bool? isProcessing,
  }) {
    return ImagesToPdfState(
      selectedImages: selectedImages ?? this.selectedImages,
      generatedPdf: generatedPdf != null ? generatedPdf() : this.generatedPdf,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

@riverpod
class ImagesToPdfViewModel extends _$ImagesToPdfViewModel {
  @override
  Future<ImagesToPdfState> build() async {
    return const ImagesToPdfState();
  }

  Future<bool> pickImages() async {
    state = const AsyncLoading();
    bool anyFileWasConverted = false;

    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      final results = await repo.pickMultipleImages();
      final validFiles = results
          .map((res) => res.$1)
          .whereType<PickedFile>()
          .toList();
      anyFileWasConverted = results.any((res) => res.$2);
      return ImagesToPdfState(selectedImages: validFiles);
    });
    return anyFileWasConverted;
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

  Future<void> convertToPdf() async {
    if (state.value == null || state.value!.selectedImages.isEmpty) return;

    state = AsyncData(state.value!.copyWith(isProcessing: true));
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      final imageBytesList = state.value!.selectedImages
          .map((file) => file.bytes)
          .toList();
      final pdfBytes = await repo.convertImagesToPdf(imageBytesList);
      return state.value!.copyWith(
        generatedPdf: () => pdfBytes,
        isProcessing: false,
      );
    });
  }

  Future<void> savePdf({required String fileName}) async {
    if (state.value?.generatedPdf == null) {
      throw Exception("No PDF to save.");
    }
    final currentState = state.value!;
    state = AsyncData(currentState.copyWith(isProcessing: true));
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.saveEncryptedDocument(
        fileName: fileName,
        data: currentState.generatedPdf!,
      );
      return currentState.copyWith(isProcessing: false);
    });
  }
}
