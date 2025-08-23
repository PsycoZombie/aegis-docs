import 'dart:typed_data';

import 'package:aegis_docs/core/media_processing/image_processor.dart';
import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_resize_provider.g.dart';

/// Represents the state for the image resizing feature.
@immutable
class ResizeState extends Equatable {
  /// Creates an instance of the resize state.
  const ResizeState({
    this.originalImage,
    this.resizedImage,
    this.originalDimensions,
    this.isAspectRatioLocked = true,
  });

  /// The original image file loaded by the user.
  final PickedFileModel? originalImage;

  /// The image data after being resized.
  final Uint8List? resizedImage;

  /// The original width and height of the image.
  final Size? originalDimensions;

  /// A flag to determine if the aspect ratio should be
  /// maintained during resizing.
  final bool isAspectRatioLocked;

  /// Creates a copy of the state with updated values.
  ResizeState copyWith({
    PickedFileModel? originalImage,
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

  @override
  List<Object?> get props => [
    originalImage,
    resizedImage,
    originalDimensions,
    isAspectRatioLocked,
  ];
}

/// A ViewModel for the image resizing feature.
///
/// Manages the state and business logic for resizing
/// an image to new dimensions,
/// with support for aspect ratio locking and presets.
@Riverpod(keepAlive: false)
class ImageResizeViewModel extends _$ImageResizeViewModel {
  /// Initializes the state by decoding the initial image to get its dimensions.
  @override
  Future<ResizeState> build(PickedFileModel? initialFile) async {
    if (initialFile == null || initialFile.bytes == null) {
      return const ResizeState();
    }

    // Decoding the image can be slow, so it's done asynchronously here.
    final decodedImage = await decodeImageFromList(initialFile.bytes!);
    final dimensions = Size(
      decodedImage.width.toDouble(),
      decodedImage.height.toDouble(),
    );

    return ResizeState(
      originalImage: initialFile,
      originalDimensions: dimensions,
    );
  }

  /// Resizes the image to the specified width and height.
  Future<void> resizeImage({required int width, required int height}) async {
    final originalImageBytes = state.value?.originalImage?.bytes;
    final originalFileName = state.value?.originalImage?.name;
    if (originalImageBytes == null || originalFileName == null) return;

    state = const AsyncLoading<ResizeState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final imageProcessor = ref.read(imageProcessorProvider);
      final outputFormat = p.extension(originalFileName).replaceAll('.', '');

      final resizedBytes = await imageProcessor.resize(
        imageBytes: originalImageBytes,
        width: width,
        height: height,
        outputFormat: outputFormat.isNotEmpty ? outputFormat : 'jpg',
      );

      return state.value!.copyWith(resizedImage: () => resizedBytes);
    });
  }

  /// Saves the resized image to the secure wallet.
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

  /// Toggles the aspect ratio lock on or off.
  void toggleAspectRatioLock() {
    if (state.value == null) return;
    state = AsyncData(
      state.value!.copyWith(
        isAspectRatioLocked: !state.value!.isAspectRatioLocked,
      ),
    );
  }

  /// Applies a preset scaling factor to the original
  /// image dimensions and resizes.
  void applyPreset({required double scale}) {
    final originalDims = state.value?.originalDimensions;
    if (originalDims == null) return;

    final newWidth = (originalDims.width * scale).round();
    final newHeight = (originalDims.height * scale).round();

    resizeImage(width: newWidth, height: newHeight);
  }
}
