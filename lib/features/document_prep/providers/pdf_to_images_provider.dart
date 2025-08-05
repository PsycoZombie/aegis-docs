import 'dart:async';
import 'dart:typed_data';

import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'document_providers.dart';

part 'pdf_to_images_provider.g.dart';

@immutable
class PdfToImagesState {
  final PickedFile? originalPdf;
  final List<Uint8List> generatedImages;
  final Set<int> selectedImageIndices;
  final bool isProcessing;

  const PdfToImagesState({
    this.originalPdf,
    this.generatedImages = const [],
    this.selectedImageIndices = const {},
    this.isProcessing = false,
  });

  PdfToImagesState copyWith({
    PickedFile? originalPdf,
    List<Uint8List>? generatedImages,
    Set<int>? selectedImageIndices,
    bool? isProcessing,
  }) {
    return PdfToImagesState(
      originalPdf: originalPdf ?? this.originalPdf,
      generatedImages: generatedImages ?? this.generatedImages,
      selectedImageIndices: selectedImageIndices ?? this.selectedImageIndices,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

@riverpod
class PdfToImagesViewModel extends _$PdfToImagesViewModel {
  @override
  Future<PdfToImagesState> build() async {
    return const PdfToImagesState();
  }

  Future<void> pickPdf() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      final pdfFile = await repo.pickPdf();
      if (pdfFile != null) {
        return const PdfToImagesState().copyWith(originalPdf: pdfFile);
      }
      return const PdfToImagesState();
    });
  }

  Future<void> convertToImages() async {
    if (state.value?.originalPdf == null) return;

    state = AsyncData(state.value!.copyWith(isProcessing: true));
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      final images = await repo.convertPdfToImages(
        state.value!.originalPdf!.bytes,
      );
      final selection = Set<int>.from(List.generate(images.length, (i) => i));
      return state.value!.copyWith(
        generatedImages: images,
        selectedImageIndices: selection,
        isProcessing: false,
      );
    });
  }

  void toggleImageSelection(int index) {
    if (state.value == null) return;
    final currentSelection = Set<int>.from(state.value!.selectedImageIndices);
    if (currentSelection.contains(index)) {
      currentSelection.remove(index);
    } else {
      currentSelection.add(index);
    }
    state = AsyncData(
      state.value!.copyWith(selectedImageIndices: currentSelection),
    );
  }

  Future<void> saveSelectedImages() async {
    if (state.value == null || state.value!.selectedImageIndices.isEmpty) {
      return;
    }

    state = AsyncData(state.value!.copyWith(isProcessing: true));

    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      final repo = await ref.read(documentRepositoryProvider.future);
      final originalFileName = currentState.originalPdf!.name.replaceAll(
        '.pdf',
        '',
      );

      for (final index in currentState.selectedImageIndices) {
        final imageBytes = currentState.generatedImages[index];
        final fileName = '${originalFileName}_page_${index + 1}.png';
        await repo.saveEncryptedDocument(fileName: fileName, data: imageBytes);
      }

      return currentState.copyWith(isProcessing: false);
    });

    if (state.hasError) {
      final previousData = state.asError!.value;
      if (previousData != null) {
        state = AsyncData(previousData.copyWith(isProcessing: false));
      }
    }
  }
}
