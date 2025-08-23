import 'dart:async';

import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'images_to_pdf_provider.g.dart';

/// Represents the state for the "Images to PDF" feature.
@immutable
class ImagesToPdfState extends Equatable {
  /// Creates an instance of the ImagesToPdfState.
  const ImagesToPdfState({
    this.selectedImages = const [],
    this.generatedPdf,
  });

  /// The list of images the user has selected for conversion,
  /// in the desired order.
  final List<PickedFileModel> selectedImages;

  /// The resulting PDF data after a successful conversion.
  final Uint8List? generatedPdf;

  /// Creates a copy of the state with updated values.
  ImagesToPdfState copyWith({
    List<PickedFileModel>? selectedImages,
    ValueGetter<Uint8List?>? generatedPdf,
  }) {
    return ImagesToPdfState(
      selectedImages: selectedImages ?? this.selectedImages,
      generatedPdf: generatedPdf != null ? generatedPdf() : this.generatedPdf,
    );
  }

  @override
  List<Object?> get props => [selectedImages, generatedPdf];
}

/// A ViewModel for the "Images to PDF" conversion feature.
///
/// Manages the list of selected images, their order, and the business logic
/// for converting them into a single PDF document.
@Riverpod(keepAlive: false)
class ImagesToPdfViewModel extends _$ImagesToPdfViewModel {
  /// Initializes the state with a list of initial image files.
  @override
  Future<ImagesToPdfState> build(List<PickedFileModel> initialFiles) async {
    return ImagesToPdfState(selectedImages: initialFiles);
  }

  /// Reorders an image in the list.
  void reorderImages(int oldIndex, int newIndex) {
    if (state.value == null) return;
    final images = List<PickedFileModel>.from(state.value!.selectedImages);
    var adjustedNewIndex = newIndex;

    // Adjust the index for reordering logic if the item is moved down the list.
    if (oldIndex < newIndex) {
      adjustedNewIndex -= 1;
    }

    final item = images.removeAt(oldIndex);
    images.insert(adjustedNewIndex, item);
    state = AsyncData(state.value!.copyWith(selectedImages: images));
  }

  /// Removes an image from the list at a specific index.
  void removeImage(int index) {
    if (state.value == null) return;
    final images = List<PickedFileModel>.from(state.value!.selectedImages)
      ..removeAt(index);
    state = AsyncData(state.value!.copyWith(selectedImages: images));
  }

  /// Converts the current list of selected images into a single PDF document.
  Future<void> convertToPdf() async {
    if (state.value == null || state.value!.selectedImages.isEmpty) return;

    state = const AsyncLoading<ImagesToPdfState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      final imageBytesList = state.value!.selectedImages
          .map((file) => file.bytes!)
          .toList();
      final pdfBytes = await repo.convertImagesToPdf(imageBytesList);
      return state.value!.copyWith(
        generatedPdf: () => pdfBytes,
      );
    });
  }

  /// Saves the generated PDF to the secure wallet.
  Future<void> savePdf({required String fileName, String? folderPath}) async {
    if (state.value?.generatedPdf == null) {
      throw Exception('No PDF to save.');
    }
    final currentState = state.value!;

    state = const AsyncLoading<ImagesToPdfState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.saveEncryptedDocument(
        fileName: fileName,
        data: currentState.generatedPdf!,
        folderPath: folderPath,
      );
      return currentState;
    });
  }
}
