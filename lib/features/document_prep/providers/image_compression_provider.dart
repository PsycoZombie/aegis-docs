import 'dart:typed_data';

import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'document_providers.dart';

part 'image_compression_provider.g.dart';

enum CompressionStatus { idle, success, failure }

@immutable
class CompressionState {
  final PickedFile? originalImage;
  final Uint8List? compressedImage;
  final int? compressedSize;
  final int targetSizeKB;
  final CompressionStatus compressionStatus;

  const CompressionState({
    this.originalImage,
    this.compressedImage,
    this.compressedSize,
    this.targetSizeKB = 100,
    this.compressionStatus = CompressionStatus.idle,
  });

  CompressionState copyWith({
    PickedFile? originalImage,
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
}

@Riverpod(keepAlive: false)
class ImageCompressionViewModel extends _$ImageCompressionViewModel {
  @override
  Future<CompressionState> build(PickedFile? initialFile) async {
    if (initialFile == null) {
      return const CompressionState();
    }
    final initialTarget = (initialFile.bytes.lengthInBytes / 1024 / 2)
        .clamp(50, 5000)
        .toInt();

    return CompressionState(
      originalImage: initialFile,
      targetSizeKB: initialTarget,
    );
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
    final originalImageBytes = state.value?.originalImage?.bytes;
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

  Future<void> saveCompressedImage({
    required String fileName,
    String? folderPath,
  }) async {
    if (state.value?.compressedImage == null) {
      throw Exception("No compressed image to save.");
    }

    final currentState = state.value!;
    final compressedBytes = currentState.compressedImage!;

    state = AsyncLoading<CompressionState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.saveEncryptedDocument(
        fileName: fileName,
        data: compressedBytes,
        folderPath: folderPath,
      );
      return currentState;
    });
  }
}
