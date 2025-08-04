// file: features/document_prep/providers/image_editing_provider.dart

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart'; // Import material.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'document_providers.dart';

part 'image_editing_provider.g.dart';

// ImageEdit and ImageEditingState classes remain the same...
class ImageEdit {
  final Uint8List bytes;
  const ImageEdit(this.bytes);
}

@immutable
class ImageEditingState {
  final Uint8List? originalImage;
  final String? originalFileName;
  final Uint8List? currentImage;
  final List<ImageEdit> editHistory;

  const ImageEditingState({
    this.originalImage,
    this.originalFileName,
    this.currentImage,
    this.editHistory = const [],
  });

  ImageEditingState copyWith({
    Uint8List? originalImage,
    String? originalFileName,
    Uint8List? currentImage,
    List<ImageEdit>? editHistory,
  }) {
    return ImageEditingState(
      originalImage: originalImage ?? this.originalImage,
      originalFileName: originalFileName ?? this.originalFileName,
      currentImage: currentImage ?? this.currentImage,
      editHistory: editHistory ?? this.editHistory,
    );
  }
}

@riverpod
class ImageEditingViewModel extends _$ImageEditingViewModel {
  @override
  Future<ImageEditingState> build() async {
    return const ImageEditingState();
  }

  Future<void> pickImage() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final picker = ref.read(filePickerServiceProvider);
      final imageFile = await picker.pickImage();

      if (imageFile != null) {
        return ImageEditingState(
          originalImage: imageFile.bytes,
          currentImage: imageFile.bytes,
          originalFileName: imageFile.name,
        );
      }
      return const ImageEditingState();
    });
  }

  void _applyNewEdit(Uint8List newImageBytes) {
    if (state.value == null) return;
    final currentState = state.value!;
    final newHistory = List<ImageEdit>.from(currentState.editHistory)
      ..add(ImageEdit(currentState.currentImage!));

    state = AsyncData(
      currentState.copyWith(
        currentImage: newImageBytes,
        editHistory: newHistory,
      ),
    );
  }

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

  Future<void> cropImage({required BuildContext context}) async {
    final currentImageBytes = state.value?.currentImage;
    if (currentImageBytes == null) return;

    state = AsyncLoading<ImageEditingState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);

      final theme = Theme.of(context);

      final croppedBytes = await repo.cropImage(
        currentImageBytes,
        theme: theme,
      );

      if (croppedBytes == null) return state.value!;

      _applyNewEdit(croppedBytes);
      return state.value!;
    });
  }

  Future<void> applyGrayscaleFilter() async {
    final currentImageBytes = state.value?.currentImage;
    if (currentImageBytes == null) return;

    state = AsyncLoading<ImageEditingState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final imageProcessor = ref.read(imageProcessorProvider);
      final grayscaleBytes = await imageProcessor.applyGrayscale(
        imageBytes: currentImageBytes,
      );

      _applyNewEdit(grayscaleBytes);
      return state.value!;
    });
  }

  Future<void> saveImage() async {
    if (state.value?.currentImage == null ||
        state.value?.originalFileName == null) {
      throw Exception("No image to save.");
    }

    final currentState = state.value!;
    final editedBytes = currentState.currentImage!;
    final fileName = "edited_${currentState.originalFileName!}";

    state = AsyncLoading<ImageEditingState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.saveEncryptedDocument(fileName: fileName, data: editedBytes);
      return currentState;
    });
  }
}
