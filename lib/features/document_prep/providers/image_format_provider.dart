import 'dart:typed_data';

import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'document_providers.dart';

part 'image_format_provider.g.dart';

@immutable
class ImageFormatState {
  final PickedFile? originalImage;
  final Uint8List? convertedImage;
  final String? originalFormat;
  final String targetFormat;
  final bool isProcessing;

  const ImageFormatState({
    this.originalImage,
    this.convertedImage,
    this.originalFormat,
    this.targetFormat = 'png',
    this.isProcessing = false,
  });

  ImageFormatState copyWith({
    PickedFile? originalImage,
    ValueGetter<Uint8List?>? convertedImage,
    String? originalFormat,
    String? targetFormat,
    bool? isProcessing,
  }) {
    return ImageFormatState(
      originalImage: originalImage ?? this.originalImage,
      convertedImage: convertedImage != null
          ? convertedImage()
          : this.convertedImage,
      originalFormat: originalFormat ?? this.originalFormat,
      targetFormat: targetFormat ?? this.targetFormat,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

@riverpod
class ImageFormatViewModel extends _$ImageFormatViewModel {
  @override
  Future<ImageFormatState> build() async {
    return const ImageFormatState();
  }

  Future<bool> pickImage() async {
    state = const AsyncLoading();
    bool wasConverted = false;

    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      final (imageFile, converted) = await repo.pickImage();
      wasConverted = converted;

      if (imageFile != null) {
        final format = p.extension(imageFile.name);
        return ImageFormatState(
          originalImage: imageFile,
          originalFormat: format,
        );
      }
      return const ImageFormatState();
    });
    return wasConverted;
  }

  void setTargetFormat(String format) {
    if (state.value == null) return;
    state = AsyncData(state.value!.copyWith(targetFormat: format));
  }

  Future<void> convertImage() async {
    if (state.value?.originalImage == null) return;

    state = AsyncData(state.value!.copyWith(isProcessing: true));

    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      final repo = await ref.read(documentRepositoryProvider.future);

      if (currentState.originalFormat == null ||
          currentState.originalFormat!.isEmpty) {
        throw Exception("Original image format is unknown.");
      }

      final convertedBytes = await repo.changeImageFormat(
        currentState.originalImage!.bytes,
        originalFormat: currentState.originalFormat!,
        targetFormat: currentState.targetFormat,
      );

      return currentState.copyWith(
        isProcessing: false,
        convertedImage: () => convertedBytes,
      );
    });
  }

  Future<void> saveImage({required String fileName}) async {
    if (state.value?.convertedImage == null) {
      throw Exception("No converted image to save.");
    }
    final currentState = state.value!;
    state = AsyncData(currentState.copyWith(isProcessing: true));
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.saveEncryptedDocument(
        fileName: fileName,
        data: currentState.convertedImage!,
      );
      return currentState.copyWith(isProcessing: false);
    });
  }
}
