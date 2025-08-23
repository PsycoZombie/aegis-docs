import 'dart:async';
import 'dart:typed_data';

import 'package:aegis_docs/core/media_processing/image_processor.dart';
import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_editing_provider.g.dart';

/// Represents a single state of the image in the
/// edit history for undo functionality.
class ImageEdit extends Equatable {
  /// Creates an instance of an image edit.
  const ImageEdit(this.bytes);

  /// The image data at a specific point in history.
  final Uint8List bytes;

  @override
  List<Object?> get props => [bytes];
}

/// Represents the state for the image editing feature.
@immutable
class ImageEditingState extends Equatable {
  /// Creates an instance of the image editing state.
  const ImageEditingState({
    this.originalImage,
    this.currentImage,
    this.editHistory = const [],
  });

  /// The original image file that was loaded into the editor.
  final PickedFileModel? originalImage;

  /// The image data as it currently appears, reflecting all applied edits.
  final Uint8List? currentImage;

  /// A stack of previous image states, used for the undo functionality.
  final List<ImageEdit> editHistory;

  /// Creates a copy of the state with updated values.
  ImageEditingState copyWith({
    PickedFileModel? originalImage,
    Uint8List? currentImage,
    List<ImageEdit>? editHistory,
  }) {
    return ImageEditingState(
      originalImage: originalImage ?? this.originalImage,
      currentImage: currentImage ?? this.currentImage,
      editHistory: editHistory ?? this.editHistory,
    );
  }

  @override
  List<Object?> get props => [originalImage, currentImage, editHistory];
}

/// A ViewModel for the image editing feature.
///
/// Manages the state of an image being edited, including an undo history,
/// and orchestrates services to apply transformations
/// like cropping and filters.
@Riverpod(keepAlive: false)
class ImageEditingViewModel extends _$ImageEditingViewModel {
  /// Initializes the editor state with an optional initial file.
  @override
  Future<ImageEditingState> build(PickedFileModel? initialFile) async {
    if (initialFile == null || initialFile.bytes == null) {
      return const ImageEditingState();
    }
    return ImageEditingState(
      originalImage: initialFile,
      currentImage: initialFile.bytes,
    );
  }

  /// Applies a new edit to the image and adds the
  /// previous state to the undo history.
  void _applyNewEdit(Uint8List newImageBytes) {
    if (state.value == null || state.value!.currentImage == null) return;
    final currentState = state.value!;
    // Add the state *before* this new edit to the history stack.
    final newHistory = List<ImageEdit>.from(currentState.editHistory)
      ..add(ImageEdit(currentState.currentImage!));

    state = AsyncData(
      currentState.copyWith(
        currentImage: newImageBytes,
        editHistory: newHistory,
      ),
    );
  }

  /// Reverts the image to its state before the last edit was applied.
  void undo() {
    if (state.value == null || state.value!.editHistory.isEmpty) return;
    final currentState = state.value!;
    final lastEdit = currentState.editHistory.last;
    final newHistory = List<ImageEdit>.from(currentState.editHistory)
      ..removeLast();

    state = AsyncData(
      currentState.copyWith(
        currentImage: lastEdit.bytes,
        editHistory: newHistory,
      ),
    );
  }

  /// Opens the interactive image cropping tool.
  Future<void> cropImage({required ThemeData theme}) async {
    final currentImageBytes = state.value?.currentImage;
    if (currentImageBytes == null) return;

    state = const AsyncLoading<ImageEditingState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      // The theme is passed to the image processor to style the crop UI.
      final croppedBytes = await repo.cropImage(
        currentImageBytes,
        theme: theme,
      );

      // If the user cancelled the crop, do nothing.
      if (croppedBytes == null) return state.value!;

      _applyNewEdit(croppedBytes);
      return state.value!;
    });
  }

  /// Applies a grayscale filter to the current image.
  Future<void> applyGrayscaleFilter() async {
    final currentImageBytes = state.value?.currentImage;
    if (currentImageBytes == null) return;

    state = const AsyncLoading<ImageEditingState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final imageProcessor = ref.read(imageProcessorProvider);
      final grayscaleBytes = await imageProcessor.applyGrayscale(
        imageBytes: currentImageBytes,
      );

      _applyNewEdit(grayscaleBytes);
      return state.value!;
    });
  }

  /// Saves the final edited image to the secure wallet.
  Future<void> saveImage({required String fileName, String? folderPath}) async {
    if (state.value?.currentImage == null) {
      throw Exception('No image to save.');
    }

    final currentState = state.value!;
    final editedBytes = currentState.currentImage!;

    state = const AsyncLoading<ImageEditingState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.saveEncryptedDocument(
        fileName: fileName,
        data: editedBytes,
        folderPath: folderPath,
      );
      return currentState;
    });
  }
}
