import 'dart:async';
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
  final String targetFormat;
  final bool isProcessing;

  const ImageFormatState({
    this.originalImage,
    this.convertedImage,
    this.targetFormat = 'png',
    this.isProcessing = false,
  });

  ImageFormatState copyWith({
    PickedFile? originalImage,
    ValueGetter<Uint8List?>? convertedImage,
    String? targetFormat,
    bool? isProcessing,
  }) {
    return ImageFormatState(
      originalImage: originalImage ?? this.originalImage,
      convertedImage: convertedImage != null
          ? convertedImage()
          : this.convertedImage,
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
        return ImageFormatState(originalImage: imageFile);
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

      final convertedBytes = await repo.changeImageFormat(
        currentState.originalImage!.bytes,
        format: currentState.targetFormat,
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
