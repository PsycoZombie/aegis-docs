import 'dart:async';

import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pdf_to_images_provider.g.dart';

/// Represents the state for the "PDF to Images" feature.
@immutable
class PdfToImagesState extends Equatable {
  /// Creates an instance of the PdfToImagesState.
  const PdfToImagesState({
    this.originalPdf,
    this.generatedImages = const [],
    this.selectedImageIndices = const {},
  });

  /// The original PDF file selected by the user for conversion.
  final PickedFileModel? originalPdf;

  /// The list of images generated from the pages of the PDF.
  final List<Uint8List> generatedImages;

  /// The set of indices corresponding to the
  /// images the user has selected to save.
  final Set<int> selectedImageIndices;

  /// Creates a copy of the state with updated values.
  PdfToImagesState copyWith({
    PickedFileModel? originalPdf,
    List<Uint8List>? generatedImages,
    Set<int>? selectedImageIndices,
  }) {
    return PdfToImagesState(
      originalPdf: originalPdf ?? this.originalPdf,
      generatedImages: generatedImages ?? this.generatedImages,
      selectedImageIndices: selectedImageIndices ?? this.selectedImageIndices,
    );
  }

  @override
  List<Object?> get props => [
    originalPdf,
    generatedImages,
    selectedImageIndices,
  ];
}

/// A ViewModel for the "PDF to Images" conversion feature.
///
/// Manages the state and business logic for extracting pages from a PDF
/// into a list of selectable images.
@Riverpod(keepAlive: false)
class PdfToImagesViewModel extends _$PdfToImagesViewModel {
  /// Initializes the state with an optional initial PDF file.
  @override
  Future<PdfToImagesState> build(PickedFileModel? initialFile) async {
    if (initialFile == null) {
      return const PdfToImagesState();
    }
    return PdfToImagesState(originalPdf: initialFile);
  }

  /// Converts the loaded PDF into a list of images, one for each page.
  /// After conversion, all images are selected by default.
  Future<void> convertToImages() async {
    if (state.value?.originalPdf?.bytes == null) return;

    state = const AsyncLoading<PdfToImagesState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      final images = await repo.convertPdfToImages(
        state.value!.originalPdf!.bytes!,
      );
      // Pre-select all generated images.
      final selection = Set<int>.from(List.generate(images.length, (i) => i));
      return state.value!.copyWith(
        generatedImages: images,
        selectedImageIndices: selection,
      );
    });
  }

  /// Toggles the selection state for a single image at the given index.
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

  /// Saves all currently selected images to the secure wallet.
  ///
  /// Each image is saved as a separate file with a page number suffix.
  Future<void> saveSelectedImages({
    required String baseName,
    String? folderPath,
  }) async {
    if (state.value == null || state.value!.selectedImageIndices.isEmpty) {
      return;
    }

    state = const AsyncLoading<PdfToImagesState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      final repo = await ref.read(documentRepositoryProvider.future);

      // Create a list of save operations to run in parallel.
      final saveFutures = currentState.selectedImageIndices.map((index) {
        final imageBytes = currentState.generatedImages[index];
        final fileName = '${baseName}_page_${index + 1}.png';
        return repo.saveEncryptedDocument(
          fileName: fileName,
          data: imageBytes,
          folderPath: folderPath,
        );
      });

      // Wait for all file save operations to complete.
      await Future.wait(saveFutures);

      return currentState;
    });
  }
}
