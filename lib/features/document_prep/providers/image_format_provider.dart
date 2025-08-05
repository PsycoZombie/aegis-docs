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

  Future<void> pickImage() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      final imageFile = await repo.pickImage();
      if (imageFile != null) {
        final format = p.extension(imageFile.name);
        return ImageFormatState(
          originalImage: imageFile,
          originalFormat: format,
        );
      }
      return const ImageFormatState();
    });
  }

  void setTargetFormat(String format) {
    if (state.value == null) return;
    state = AsyncData(state.value!.copyWith(targetFormat: format));
  }

  Future<void> convertAndSaveImage() async {
    if (state.value?.originalImage == null) return;

    state = AsyncData(state.value!.copyWith(isProcessing: true));

    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      final repo = await ref.read(documentRepositoryProvider.future);

      if (currentState.originalFormat == null) {
        throw Exception("Original image format is unknown.");
      }

      final convertedBytes = await repo.changeImageFormat(
        currentState.originalImage!.bytes,
        originalFormat: currentState.originalFormat!,
        targetFormat: currentState.targetFormat,
      );

      final originalName = p.basenameWithoutExtension(
        currentState.originalImage!.name,
      );
      final newFileName = '$originalName.${currentState.targetFormat}';

      await repo.saveEncryptedDocument(
        fileName: newFileName,
        data: convertedBytes,
      );

      return currentState.copyWith(
        isProcessing: false,
        convertedImage: () => convertedBytes,
      );
    });

    if (state.hasError) {
      final previousData = state.asError!.value;
      if (previousData != null) {
        state = AsyncData(previousData.copyWith(isProcessing: false));
      }
    }
  }
}
