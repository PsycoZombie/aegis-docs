import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'document_providers.dart';

part 'resize_tool_provider.g.dart';

@immutable
class ResizeState {
  final Uint8List? originalImage;
  final Uint8List? resizedImage;
  final String? originalFileName;
  final Size? originalDimensions;
  final bool isAspectRatioLocked;

  const ResizeState({
    this.originalImage,
    this.resizedImage,
    this.originalFileName,
    this.originalDimensions,
    this.isAspectRatioLocked = true,
  });

  ResizeState copyWith({
    Uint8List? originalImage,
    ValueGetter<Uint8List?>? resizedImage,
    String? originalFileName,
    Size? originalDimensions,
    bool? isAspectRatioLocked,
  }) {
    return ResizeState(
      originalImage: originalImage ?? this.originalImage,
      resizedImage: resizedImage != null ? resizedImage() : this.resizedImage,
      originalFileName: originalFileName ?? this.originalFileName,
      originalDimensions: originalDimensions ?? this.originalDimensions,
      isAspectRatioLocked: isAspectRatioLocked ?? this.isAspectRatioLocked,
    );
  }
}

@riverpod
class ResizeToolViewModel extends _$ResizeToolViewModel {
  @override
  Future<ResizeState> build() async {
    return const ResizeState();
  }

  Future<void> pickImage() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final picker = ref.read(filePickerServiceProvider);
      final imageFile = await picker.pickImage();

      if (imageFile != null) {
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
      return const ResizeState();
    });
  }

  Future<void> resizeImage({required int width, required int height}) async {
    final originalImageBytes = state.value?.originalImage;
    final originalFileName = state.value?.originalFileName;
    if (originalImageBytes == null) return;

    state = AsyncLoading<ResizeState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final imageProcessor = ref.read(imageProcessorProvider);
      final outputFormat = p.extension(originalFileName!);
      final resizedBytes = await imageProcessor.resize(
        imageBytes: originalImageBytes,
        width: width,
        height: height,
        outputFormat: outputFormat.isNotEmpty ? outputFormat : '.jpg',
      );
      return state.value!.copyWith(resizedImage: () => resizedBytes);
    });
  }

  Future<void> saveResizedImage({required String fileName}) async {
    if (state.value?.resizedImage == null) {
      throw Exception("No resized image available to save.");
    }

    final currentState = state.value!;
    final resizedBytes = currentState.resizedImage!;

    state = AsyncLoading<ResizeState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.saveEncryptedDocument(fileName: fileName, data: resizedBytes);
      return currentState;
    });
  }

  void toggleAspectRatioLock() {
    state = AsyncValue.data(
      state.value!.copyWith(
        isAspectRatioLocked: !state.value!.isAspectRatioLocked,
      ),
    );
  }

  void applyPreset({required double scale}) {
    final originalDims = state.value?.originalDimensions;
    if (originalDims == null) return;

    final newWidth = (originalDims.width * scale).round();
    final newHeight = (originalDims.height * scale).round();

    resizeImage(width: newWidth, height: newHeight);
  }

  void clearResizedImage() {
    state = AsyncValue.data(state.value!.copyWith(resizedImage: () => null));
  }
}
