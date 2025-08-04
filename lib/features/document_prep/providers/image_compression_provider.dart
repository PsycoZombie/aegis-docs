import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'document_providers.dart';

part 'image_compression_provider.g.dart';

enum CompressionStatus { idle, success, failure }

@immutable
class CompressionState {
  final Uint8List? originalImage;
  final Uint8List? compressedImage;
  final String? originalFileName;
  final int? originalSize;
  final int? compressedSize;
  final int targetSizeKB;
  final CompressionStatus compressionStatus;

  const CompressionState({
    this.originalImage,
    this.compressedImage,
    this.originalFileName,
    this.originalSize,
    this.compressedSize,
    this.targetSizeKB = 100,
    this.compressionStatus = CompressionStatus.idle,
  });

  CompressionState copyWith({
    Uint8List? originalImage,
    ValueGetter<Uint8List?>? compressedImage,
    String? originalFileName,
    int? originalSize,
    ValueGetter<int?>? compressedSize,
    int? targetSizeKB,
    CompressionStatus? compressionStatus,
  }) {
    return CompressionState(
      originalImage: originalImage ?? this.originalImage,
      compressedImage: compressedImage != null
          ? compressedImage()
          : this.compressedImage,
      originalFileName: originalFileName ?? this.originalFileName,
      originalSize: originalSize ?? this.originalSize,
      compressedSize: compressedSize != null
          ? compressedSize()
          : this.compressedSize,
      targetSizeKB: targetSizeKB ?? this.targetSizeKB,
      compressionStatus: compressionStatus ?? this.compressionStatus,
    );
  }
}

@riverpod
class ImageCompressionViewModel extends _$ImageCompressionViewModel {
  @override
  Future<CompressionState> build() async {
    return const CompressionState();
  }

  Future<void> pickImage() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final picker = ref.read(filePickerServiceProvider);
      final imageFile = await picker.pickImage();

      if (imageFile != null) {
        return CompressionState(
          originalImage: imageFile.bytes,
          originalFileName: imageFile.name,
          originalSize: imageFile.bytes.lengthInBytes,
        );
      }
      return const CompressionState();
    });
  }

  void setTargetSize(int kb) {
    if (state.value == null) return;
    state = AsyncData(
      state.value!.copyWith(
        targetSizeKB: kb,
        compressionStatus: CompressionStatus.idle,
      ),
    );
  }

  Future<void> compressImage() async {
    final originalImageBytes = state.value?.originalImage;
    if (originalImageBytes == null) return;

    state = AsyncLoading<CompressionState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final imageProcessor = ref.read(imageProcessorProvider);
      final targetBytes = state.value!.targetSizeKB * 1024;

      int quality = 95;
      Uint8List? bestCompressedImage;

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

  Future<void> saveCompressedImage() async {
    if (state.value?.compressedImage == null ||
        state.value?.originalFileName == null) {
      throw Exception("No compressed image to save.");
    }

    final currentState = state.value!;
    final compressedBytes = currentState.compressedImage!;
    final fileName = "compressed_${currentState.originalFileName!}";

    state = AsyncLoading<CompressionState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.saveEncryptedDocument(
        fileName: fileName,
        data: compressedBytes,
      );
      return currentState;
    });
  }
}
