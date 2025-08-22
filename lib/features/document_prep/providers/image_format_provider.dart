import 'dart:typed_data';

import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/features/document_prep/providers/document_providers.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_format_provider.g.dart';

@immutable
class ImageFormatState {

  const ImageFormatState({
    this.originalImage,
    this.convertedImage,
    this.originalFormat,
    this.targetFormat = 'png',
    this.isProcessing = false,
  });
  final PickedFile? originalImage;
  final Uint8List? convertedImage;
  final String? originalFormat;
  final String targetFormat;
  final bool isProcessing;

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

@Riverpod(keepAlive: false)
class ImageFormatViewModel extends _$ImageFormatViewModel {
  @override
  Future<ImageFormatState> build(PickedFile? initialFile) async {
    if (initialFile == null) {
      return const ImageFormatState();
    }
    final format = p.extension(initialFile.name);
    return ImageFormatState(originalImage: initialFile, originalFormat: format);
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
        throw Exception('Original image format is unknown.');
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

  Future<void> saveImage({required String fileName, String? folderPath}) async {
    if (state.value?.convertedImage == null) {
      throw Exception('No converted image to save.');
    }
    final currentState = state.value!;
    state = AsyncData(currentState.copyWith(isProcessing: true));
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.saveEncryptedDocument(
        fileName: fileName,
        data: currentState.convertedImage!,
        folderPath: folderPath,
      );
      return currentState.copyWith(isProcessing: false);
    });
  }
}
