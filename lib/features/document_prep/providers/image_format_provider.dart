import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_format_provider.g.dart';

/// Represents the state for the image format conversion feature.
@immutable
class ImageFormatState extends Equatable {
  /// Creates an instance of the image format state.
  const ImageFormatState({
    this.originalImage,
    this.convertedImage,
    this.originalFormat,
    this.targetFormat = 'png',
  });

  /// The original image file loaded by the user.
  final PickedFileModel? originalImage;

  /// The image data after being converted to the [targetFormat].
  final Uint8List? convertedImage;

  /// The file extension of the original image (e.g., ".jpg").
  final String? originalFormat;

  /// The desired output format for the conversion (e.g., "png").
  final String targetFormat;

  /// Creates a copy of the state with updated values.
  ImageFormatState copyWith({
    PickedFileModel? originalImage,
    ValueGetter<Uint8List?>? convertedImage,
    String? originalFormat,
    String? targetFormat,
  }) {
    return ImageFormatState(
      originalImage: originalImage ?? this.originalImage,
      convertedImage: convertedImage != null
          ? convertedImage()
          : this.convertedImage,
      originalFormat: originalFormat ?? this.originalFormat,
      targetFormat: targetFormat ?? this.targetFormat,
    );
  }

  @override
  List<Object?> get props => [
    originalImage,
    convertedImage,
    originalFormat,
    targetFormat,
  ];
}

/// A ViewModel for the image format conversion feature.
///
/// Manages the state and business logic for changing an image's file type
/// (e.g., from JPG to PNG).
@Riverpod(keepAlive: false)
class ImageFormatViewModel extends _$ImageFormatViewModel {
  /// Initializes the state with an optional
  /// initial file, extracting its format.
  @override
  Future<ImageFormatState> build(PickedFileModel? initialFile) async {
    if (initialFile == null) {
      return const ImageFormatState();
    }
    final format = p.extension(initialFile.name).replaceAll('.', '');
    return ImageFormatState(originalImage: initialFile, originalFormat: format);
  }

  /// Updates the target format for the next conversion.
  void setTargetFormat(String format) {
    if (state.value == null) return;
    state = AsyncData(state.value!.copyWith(targetFormat: format));
  }

  /// Performs the image format conversion.
  Future<void> convertImage() async {
    if (state.value?.originalImage?.bytes == null) return;

    // Set the state to loading while preserving the previous data for the UI.
    state = const AsyncLoading<ImageFormatState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      final repo = await ref.read(documentRepositoryProvider.future);

      if (currentState.originalFormat == null ||
          currentState.originalFormat!.isEmpty) {
        throw Exception('Original image format is unknown.');
      }

      final convertedBytes = await repo.changeImageFormat(
        currentState.originalImage!.bytes!,
        originalFormat: currentState.originalFormat!,
        targetFormat: currentState.targetFormat,
      );

      return currentState.copyWith(
        convertedImage: () => convertedBytes,
      );
    });
  }

  /// Saves the converted image to the secure wallet.
  Future<void> saveImage({required String fileName, String? folderPath}) async {
    if (state.value?.convertedImage == null) {
      throw Exception('No converted image to save.');
    }
    final currentState = state.value!;

    state = const AsyncLoading<ImageFormatState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.saveEncryptedDocument(
        fileName: fileName,
        data: currentState.convertedImage!,
        folderPath: folderPath,
      );
      // Return the current state to keep the UI showing the result.
      return currentState;
    });
  }
}
