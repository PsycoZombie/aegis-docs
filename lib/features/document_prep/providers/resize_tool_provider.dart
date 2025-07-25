// features/document_prep/providers/resize_tool_provider.dart

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'document_providers.dart'; // Your existing providers

part 'resize_tool_provider.g.dart';

/// Represents the state for the image resizing tool.
@immutable
class ResizeState {
  final Uint8List? originalImage;
  final Uint8List? resizedImage;
  final String? originalFileName;
  final Size? originalDimensions;

  const ResizeState({
    this.originalImage,
    this.resizedImage,
    this.originalFileName,
    this.originalDimensions,
  });

  // Helper method to create a copy of the state with new values.
  ResizeState copyWith({
    Uint8List? originalImage,
    Uint8List? resizedImage,
    String? originalFileName,
    Size? originalDimensions,
    // Use ValueGetter to allow explicitly setting a property to null
  }) {
    return ResizeState(
      originalImage: originalImage ?? this.originalImage,
      resizedImage: resizedImage ?? this.resizedImage,
      originalFileName: originalFileName ?? this.originalFileName,
      originalDimensions: originalDimensions ?? this.originalDimensions,
    );
  }
}

/// ViewModel for the Resize Tool.
@riverpod
class ResizeToolViewModel extends _$ResizeToolViewModel {
  @override
  Future<ResizeState> build() async {
    // Initial state is empty.
    return const ResizeState();
  }

  /// Picks an image from the device and sets it as the original image.
  Future<void> pickImage() async {
    state = const AsyncLoading(); // Set loading state
    state = await AsyncValue.guard(() async {
      final picker = ref.read(filePickerServiceProvider);
      final imageFile = await picker.pickImage();

      if (imageFile != null) {
        // Decode image to get dimensions
        final decodedImage = await decodeImageFromList(imageFile.bytes);
        final dimensions = Size(
          decodedImage.width.toDouble(),
          decodedImage.height.toDouble(),
        );

        return ResizeState(
          originalImage: imageFile.bytes,
          originalFileName: imageFile.name,
          originalDimensions: dimensions,
        );
      }
      return const ResizeState(); // Return empty state if user cancels
    });
  }

  /// Resizes the original image based on the provided dimensions.
  Future<void> resizeImage({required int width, required int height}) async {
    // Get the current data from the state
    final originalImageBytes = state.value?.originalImage;
    if (originalImageBytes == null) return;

    // Set state to loading, but keep the current data for the UI
    state = AsyncLoading<ResizeState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final imageProcessor = ref.read(imageProcessorProvider);
      final resizedBytes = await imageProcessor.resize(
        imageBytes: originalImageBytes,
        width: width,
        height: height,
      );
      // Return a new state with the resized image included
      return state.value!.copyWith(resizedImage: resizedBytes);
    });
  }

  /// Saves the currently resized image to encrypted local storage.
  Future<void> saveResizedImage() async {
    // Ensure we have a valid state with a resized image and a filename.
    if (state.value?.resizedImage == null ||
        state.value?.originalFileName == null) {
      throw Exception("No resized image or filename available to save.");
    }

    final currentState = state.value!;
    final resizedBytes = currentState.resizedImage!;
    final fileName = "resized_${currentState.originalFileName!}";

    // Set state to loading, but keep showing the current data
    state = AsyncLoading<ResizeState>().copyWithPrevious(state);

    // Guard against errors during the save operation
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.saveEncryptedDocument(fileName: fileName, data: resizedBytes);
      return currentState;
    });
  }
}
