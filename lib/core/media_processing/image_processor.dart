import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

// --- Isolate Payloads --- //

/// A payload for passing image resizing parameters to a separate isolate.
class _ResizePayload {
  _ResizePayload(this.imageBytes, this.width, this.height, this.outputFormat);
  final Uint8List imageBytes;
  final int width;
  final int height;
  final String outputFormat;
}

/// A payload for passing image compression parameters to a separate isolate.
class _CompressPayload {
  _CompressPayload(this.imageBytes, this.quality);
  final Uint8List imageBytes;
  final int quality;
}

/// A payload for passing image format conversion
/// parameters to a separate isolate.
class _FormatChangePayload {
  _FormatChangePayload(this.imageBytes, this.originalFormat, this.targetFormat);
  final Uint8List imageBytes;
  final String originalFormat;
  final String targetFormat;
}

// --- Isolate Entry Points --- //

/// Isolate entry point for resizing an image.
Uint8List _resizeIsolate(_ResizePayload payload) {
  final image = img.decodeImage(payload.imageBytes);
  if (image == null) {
    throw Exception('Failed to decode image for resizing.');
  }
  final resized = img.copyResize(
    image,
    width: payload.width,
    height: payload.height,
  );
  if (payload.outputFormat.toLowerCase() == '.png') {
    return Uint8List.fromList(img.encodePng(resized));
  } else {
    return Uint8List.fromList(img.encodeJpg(resized));
  }
}

/// Isolate entry point for compressing an image.
Uint8List _compressIsolate(_CompressPayload payload) {
  final image = img.decodeImage(payload.imageBytes);
  if (image == null) {
    throw Exception('Failed to decode image for compression.');
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: payload.quality));
}

/// Isolate entry point for changing an image's format.
Uint8List _formatChangeIsolate(_FormatChangePayload payload) {
  img.Image? image;
  // Decode the image based on its original format.
  switch (payload.originalFormat.toLowerCase()) {
    case '.jpg':
    case '.jpeg':
      image = img.decodeJpg(payload.imageBytes);
    case '.png':
      image = img.decodePng(payload.imageBytes);
    case '.gif':
      image = img.decodeGif(payload.imageBytes);
    // ... add other specific decoders as needed
    default:
      // Fallback to the generic decoder for other supported formats.
      image = img.decodeImage(payload.imageBytes);
  }

  if (image == null) {
    throw Exception('Failed to decode image for format conversion.');
  }

  // Encode the image into the target format.
  switch (payload.targetFormat.toLowerCase()) {
    case 'png':
      return Uint8List.fromList(img.encodePng(image));
    case 'gif':
      return Uint8List.fromList(img.encodeGif(image));
    // ... add other specific encoders as needed
    case 'jpg':
    default:
      return Uint8List.fromList(img.encodeJpg(image));
  }
}

/// Isolate entry point for applying a grayscale filter.
Uint8List _grayscaleIsolate(Uint8List imageBytes) {
  final image = img.decodeImage(imageBytes);
  if (image == null) {
    throw Exception('Failed to decode image for grayscale filter.');
  }
  final grayscaleImage = img.grayscale(image);
  return Uint8List.fromList(img.encodeJpg(grayscaleImage));
}

/// Provides an instance of [ImageProcessor] for dependency injection.
final imageProcessorProvider = Provider<ImageProcessor>((ref) {
  return ImageProcessor();
});

/// A service for performing image manipulation tasks.
///
/// This class encapsulates image processing logic,
/// such as resizing, compressing,
/// cropping, and format conversion. It offloads heavy computations to separate
/// isolates to prevent blocking the UI thread,
/// ensuring the app remains responsive.
class ImageProcessor {
  /// Creates an instance of [ImageProcessor].
  /// An optional [imageCropper] instance can be provided for testing purposes.
  ImageProcessor({
    ImageCropper? imageCropper,
    FileSystem? fileSystem,
  }) : _imageCropper = imageCropper ?? ImageCropper(),
       _fileSystem = fileSystem ?? const LocalFileSystem();

  final ImageCropper _imageCropper;
  final FileSystem _fileSystem;

  /// Resizes an image to the specified dimensions.
  ///
  /// This operation is performed in an isolate to avoid UI jank.
  Future<Uint8List> resize({
    required Uint8List imageBytes,
    required int width,
    required int height,
    required String outputFormat,
  }) async {
    return compute(
      _resizeIsolate,
      _ResizePayload(imageBytes, width, height, outputFormat),
    );
  }

  /// Compresses an image to reduce its file size using JPEG compression.
  Future<Uint8List> compressImage({
    required Uint8List imageBytes,
    int quality = 100,
  }) async {
    final clampedQuality = quality.clamp(0, 100);
    return compute(
      _compressIsolate,
      _CompressPayload(imageBytes, clampedQuality),
    );
  }

  /// Changes the format of an image (e.g., from PNG to JPG).
  Future<Uint8List> changeFormat({
    required Uint8List imageBytes,
    required String originalFormat,
    required String targetFormat,
  }) async {
    return compute(
      _formatChangeIsolate,
      _FormatChangePayload(imageBytes, originalFormat, targetFormat),
    );
  }

  /// Opens a native user interface for cropping an image.
  ///
  /// Returns the cropped image bytes, or null if the user cancels.
  /// Opens a native user interface for cropping an image.
  Future<Uint8List?> crop({
    required Uint8List imageBytes,
    required ThemeData theme,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/temp_crop_image.jpg';
    final file = await _fileSystem.file(tempPath).writeAsBytes(imageBytes);
    final colorScheme = theme.colorScheme;

    final croppedFile = await _imageCropper.cropImage(
      sourcePath: file.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: colorScheme.primary,
          statusBarColor: colorScheme.primary,
          toolbarWidgetColor: colorScheme.onPrimary,
          backgroundColor: theme.scaffoldBackgroundColor,
          activeControlsWidgetColor: colorScheme.secondary,
          lockAspectRatio: false,
        ),
      ],
    );

    await file.delete();

    if (croppedFile != null) {
      // THE FIX: Use the injected file system to read the cropped file.
      return _fileSystem.file(croppedFile.path).readAsBytes();
    }

    return null;
  }

  /// Applies a grayscale (black and white) filter to an image.
  Future<Uint8List> applyGrayscale({required Uint8List imageBytes}) async {
    return compute(_grayscaleIsolate, imageBytes);
  }
}
