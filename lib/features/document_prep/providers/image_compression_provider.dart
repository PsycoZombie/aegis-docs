import 'package:aegis_docs/core/media_processing/image_processor.dart';
import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_compression_provider.g.dart';

/// Represents the status of the compression operation.
// ignore: public_member_api_docs
enum CompressionStatus { idle, success, failure }

/// Represents the state for the image compression feature.
@immutable
class CompressionState extends Equatable {
  /// Creates an instance of the compression state.
  const CompressionState({
    this.originalImage,
    this.compressedImage,
    this.compressedSize,
    this.targetSizeKB = 100,
    this.compressionStatus = CompressionStatus.idle,
  });

  /// The original, uncompressed image file.
  final PickedFileModel? originalImage;

  /// The resulting compressed image data.
  final Uint8List? compressedImage;

  /// The size of the compressed image in bytes.
  final int? compressedSize;

  /// The user-defined target size for the compression in kilobytes.
  final int targetSizeKB;

  /// The current status of the most recent compression attempt.
  final CompressionStatus compressionStatus;

  /// Creates a copy of the state with updated values.
  CompressionState copyWith({
    PickedFileModel? originalImage,
    ValueGetter<Uint8List?>? compressedImage,
    ValueGetter<int?>? compressedSize,
    int? targetSizeKB,
    CompressionStatus? compressionStatus,
  }) {
    return CompressionState(
      originalImage: originalImage ?? this.originalImage,
      compressedImage: compressedImage != null
          ? compressedImage()
          : this.compressedImage,
      compressedSize: compressedSize != null
          ? compressedSize()
          : this.compressedSize,
      targetSizeKB: targetSizeKB ?? this.targetSizeKB,
      compressionStatus: compressionStatus ?? this.compressionStatus,
    );
  }

  @override
  List<Object?> get props => [
    originalImage,
    compressedImage,
    compressedSize,
    targetSizeKB,
    compressionStatus,
  ];
}

/// A ViewModel (using Riverpod) for the image compression feature.
///
/// This provider manages the state ([CompressionState]) and business logic for
/// compressing an image to a target size.
@Riverpod(keepAlive: false)
class ImageCompressionViewModel extends _$ImageCompressionViewModel {
  /// Initializes the state with an optional initial file.
  @override
  Future<CompressionState> build(PickedFileModel? initialFile) async {
    if (initialFile == null || initialFile.bytes == null) {
      return const CompressionState();
    }
    // Set a reasonable initial target size, e.g., 50% of the original size.
    final initialTarget = (initialFile.bytes!.lengthInBytes / 1024 / 2)
        .clamp(50, 5000)
        .toInt();

    return CompressionState(
      originalImage: initialFile,
      targetSizeKB: initialTarget,
    );
  }

  /// Updates the target compression size.
  void setTargetSize(int kb) {
    if (state.value == null) return;
    state = AsyncData(
      state.value!.copyWith(
        targetSizeKB: kb,
        compressionStatus: CompressionStatus.idle,
      ),
    );
  }

  /// Runs the image compression algorithm.
  ///
  /// It iteratively reduces the JPEG quality until the file size is below the
  // ignore: comment_references
  /// [targetSizeKB]. The state is updated with the result.
  Future<void> compressImage() async {
    final originalImageBytes = state.value?.originalImage?.bytes;
    if (originalImageBytes == null) return;

    state = const AsyncLoading<CompressionState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final imageProcessor = ref.read(imageProcessorProvider);
      final targetBytes = state.value!.targetSizeKB * 1024;

      var quality = 95;
      Uint8List? bestCompressedImage;

      // Iteratively lower quality to find the best fit under the target size.
      while (quality > 10) {
        final compressed = await imageProcessor.compressImage(
          imageBytes: originalImageBytes,
          quality: quality,
        );
        if (compressed.lengthInBytes <= targetBytes) {
          bestCompressedImage = compressed;
          break;
        }
        quality -= 5;
      }

      // Handle cases where compression was not possible or didn't reduce size.
      if (bestCompressedImage == null ||
          bestCompressedImage.lengthInBytes >=
              originalImageBytes.lengthInBytes) {
        return state.value!.copyWith(
          compressedImage: () => originalImageBytes,
          compressedSize: () => originalImageBytes.lengthInBytes,
          compressionStatus: CompressionStatus.failure,
        );
      }

      return state.value!.copyWith(
        compressedImage: () => bestCompressedImage,
        compressedSize: () => bestCompressedImage!.lengthInBytes,
        compressionStatus: CompressionStatus.success,
      );
    });
  }

  /// Saves the compressed image to the secure wallet.
  Future<void> saveCompressedImage({
    required String fileName,
    String? folderPath,
  }) async {
    if (state.value?.compressedImage == null) {
      throw Exception('No compressed image to save.');
    }

    final currentState = state.value!;
    final compressedBytes = currentState.compressedImage!;

    state = const AsyncLoading<CompressionState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.saveEncryptedDocument(
        fileName: fileName,
        data: compressedBytes,
        folderPath: folderPath,
      );
      // Return the original state to keep the UI showing the compressed result.
      return currentState;
    });
  }
}
