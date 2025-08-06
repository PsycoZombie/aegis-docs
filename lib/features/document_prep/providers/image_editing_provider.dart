import 'dart:async';
import 'dart:typed_data';

import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'document_providers.dart';

part 'image_editing_provider.g.dart';

class ImageEdit {
  final Uint8List bytes;
  const ImageEdit(this.bytes);
}

@immutable
class ImageEditingState {
  final PickedFile? originalImage;
  final Uint8List? currentImage;
  final List<ImageEdit> editHistory;

  const ImageEditingState({
    this.originalImage,
    this.currentImage,
    this.editHistory = const [],
  });

  ImageEditingState copyWith({
    PickedFile? originalImage,
    Uint8List? currentImage,
    List<ImageEdit>? editHistory,
  }) {
    return ImageEditingState(
      originalImage: originalImage ?? this.originalImage,
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

  Future<bool> pickImage() async {
    state = const AsyncLoading();
    bool wasConverted = false;

    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      final (imageFile, converted) = await repo.pickImage();
      wasConverted = converted;

      if (imageFile != null) {
        return ImageEditingState(
          originalImage: imageFile,
          currentImage: imageFile.bytes,
        );
      }
      return const ImageEditingState();
    });
    return wasConverted;
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
      if (context.mounted) {
        final theme = Theme.of(context);
        final croppedBytes = await repo.cropImage(
          currentImageBytes,
          theme: theme,
        );

        if (croppedBytes == null) return state.value!;

        _applyNewEdit(croppedBytes);
      }
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

  Future<void> saveImage({required String fileName}) async {
    if (state.value?.currentImage == null) {
      throw Exception("No image to save.");
    }

    final currentState = state.value!;
    final editedBytes = currentState.currentImage!;

    state = AsyncLoading<ImageEditingState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.saveEncryptedDocument(fileName: fileName, data: editedBytes);
      return currentState;
    });
  }
}
