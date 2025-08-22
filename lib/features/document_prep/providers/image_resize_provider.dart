import 'dart:async';
import 'dart:typed_data';

import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/features/document_prep/providers/document_providers.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_resize_provider.g.dart';

@immutable
class ResizeState {

  const ResizeState({
    this.originalImage,
    this.resizedImage,
    this.originalDimensions,
    this.isAspectRatioLocked = true,
  });
  final PickedFile? originalImage;
  final Uint8List? resizedImage;
  final Size? originalDimensions;
  final bool isAspectRatioLocked;

  ResizeState copyWith({
    PickedFile? originalImage,
    ValueGetter<Uint8List?>? resizedImage,
    Size? originalDimensions,
    bool? isAspectRatioLocked,
  }) {
    return ResizeState(
      originalImage: originalImage ?? this.originalImage,
      resizedImage: resizedImage != null ? resizedImage() : this.resizedImage,
      originalDimensions: originalDimensions ?? this.originalDimensions,
      isAspectRatioLocked: isAspectRatioLocked ?? this.isAspectRatioLocked,
    );
  }
}

@Riverpod(keepAlive: false)
class ImageResizeViewModel extends _$ImageResizeViewModel {
  @override
  Future<ResizeState> build(PickedFile? initialFile) async {
    if (initialFile == null) {
      return const ResizeState();
    }

    final decodedImage = await decodeImageFromList(initialFile.bytes);
    final dimensions = Size(
      decodedImage.width.toDouble(),
      decodedImage.height.toDouble(),
    );

    return ResizeState(
      originalImage: initialFile,
      originalDimensions: dimensions,
    );
  }

  Future<void> resizeImage({required int width, required int height}) async {
    final originalImageBytes = state.value?.originalImage?.bytes;
    final originalFileName = state.value?.originalImage?.name;
    if (originalImageBytes == null || originalFileName == null) return;

    state = const AsyncLoading<ResizeState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final imageProcessor = ref.read(imageProcessorProvider);
      final outputFormat = p.extension(originalFileName);

      final resizedBytes = await imageProcessor.resize(
        imageBytes: originalImageBytes,
        width: width,
        height: height,
        outputFormat: outputFormat.isNotEmpty ? outputFormat : '.jpg',
      );

      return state.value!.copyWith(resizedImage: () => resizedBytes);
    });
  }

  Future<void> saveResizedImage({
    required String fileName,
    String? folderPath,
  }) async {
    if (state.value?.resizedImage == null) {
      throw Exception('No resized image available to save.');
    }

    final currentState = state.value!;
    final resizedBytes = currentState.resizedImage!;

    state = const AsyncLoading<ResizeState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.saveEncryptedDocument(
        fileName: fileName,
        data: resizedBytes,
        folderPath: folderPath,
      );
      return currentState;
    });
  }

  void toggleAspectRatioLock() {
    state = AsyncData(
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
}
