import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeData;
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

class _ResizePayload {
  final Uint8List imageBytes;
  final int width;
  final int height;
  final String outputFormat;

  _ResizePayload(this.imageBytes, this.width, this.height, this.outputFormat);
}

class _CompressPayload {
  final Uint8List imageBytes;
  final int quality;

  _CompressPayload(this.imageBytes, this.quality);
}

Uint8List _resizeIsolate(_ResizePayload payload) {
  final image = img.decodeImage(payload.imageBytes);
  if (image == null) {
    throw Exception("Failed to decode image for resizing.");
  }
  final resized = img.copyResize(
    image,
    width: payload.width,
    height: payload.height,
  );
  if (payload.outputFormat.toLowerCase() == '.png') {
    return Uint8List.fromList(img.encodePng(resized));
  } else {
    return Uint8List.fromList(img.encodeJpg(resized, quality: 100));
  }
}

Uint8List _compressIsolate(_CompressPayload payload) {
  final image = img.decodeImage(payload.imageBytes);
  if (image == null) {
    throw Exception("Failed to decode image for compression.");
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: payload.quality));
}

Uint8List _formatChangeIsolate(Map<String, dynamic> params) {
  final bytes = params['bytes'] as Uint8List;
  final originalFormat = params['originalFormat'] as String;
  final targetFormat = params['targetFormat'] as String;

  img.Image? image;
  switch (originalFormat.toLowerCase()) {
    case '.jpg':
    case '.jpeg':
      image = img.decodeJpg(bytes);
      break;
    case '.png':
      image = img.decodePng(bytes);
      break;
    case '.gif':
      image = img.decodeGif(bytes);
      break;
    case '.bmp':
      image = img.decodeBmp(bytes);
      break;
    case '.ico':
      image = img.decodeIco(bytes);
      break;
    case '.tiff':
      image = img.decodeTiff(bytes);
      break;
    case '.tga':
      image = img.decodeTga(bytes);
      break;
    case '.pvr':
      image = img.decodePvr(bytes);
      break;
    case '.psd':
      image = img.decodePsd(bytes);
      break;
    case '.webp':
      image = img.decodeWebP(bytes);
      break;
    default:
      image = img.decodeImage(bytes);
  }

  if (image == null) {
    throw Exception("Failed to decode image for format conversion.");
  }
  switch (targetFormat.toLowerCase()) {
    case 'png':
      return Uint8List.fromList(img.encodePng(image));
    case 'gif':
      return Uint8List.fromList(img.encodeGif(image));
    case 'bmp':
      return Uint8List.fromList(img.encodeBmp(image));
    case 'ico':
      return Uint8List.fromList(img.encodeIco(image));
    case 'tiff':
      return Uint8List.fromList(img.encodeTiff(image));
    case 'tga':
      return Uint8List.fromList(img.encodeTga(image));
    case 'pvr':
      return Uint8List.fromList(img.encodePvr(image));
    case 'jpg':
    default:
      return Uint8List.fromList(img.encodeJpg(image));
  }
}

class ImageProcessor {
  Future<Uint8List> resize({
    required Uint8List imageBytes,
    required int width,
    required int height,
    required String outputFormat,
  }) async {
    return await compute(
      _resizeIsolate,
      _ResizePayload(imageBytes, width, height, outputFormat),
    );
  }

  Future<Uint8List> compressImage({
    required Uint8List imageBytes,
    int quality = 85,
  }) async {
    final clampedQuality = quality.clamp(0, 100);
    return await compute(
      _compressIsolate,
      _CompressPayload(imageBytes, clampedQuality),
    );
  }

  Future<Uint8List> changeFormat({
    required Uint8List imageBytes,
    required String originalFormat,
    required String targetFormat,
  }) async {
    return await compute(_formatChangeIsolate, {
      'bytes': imageBytes,
      'originalformat': originalFormat,
      'targetFormat': targetFormat,
    });
  }

  Future<Uint8List?> crop({
    required Uint8List imageBytes,
    required ThemeData theme,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/temp_crop_image.jpg';
    final file = await File(tempPath).writeAsBytes(imageBytes);
    final colorScheme = theme.colorScheme;

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: colorScheme.primary,
          statusBarColor: colorScheme.primary,
          toolbarWidgetColor: colorScheme.onPrimary,
          backgroundColor: theme.scaffoldBackgroundColor,
          activeControlsWidgetColor: colorScheme.secondary,
          cropFrameColor: colorScheme.primary,
          cropGridColor: colorScheme.onPrimary.withAlpha((0.7 * 255).toInt()),
          lockAspectRatio: false,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
      ],
    );

    await file.delete();

    if (croppedFile != null) {
      return await croppedFile.readAsBytes();
    }

    return null;
  }

  Uint8List _grayscaleIsolate(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception("Failed to decode image for grayscale filter.");
    }
    final grayscaleImage = img.grayscale(image);
    return Uint8List.fromList(img.encodeJpg(grayscaleImage));
  }

  Future<Uint8List> applyGrayscale({required Uint8List imageBytes}) async {
    return await compute(_grayscaleIsolate, imageBytes);
  }
}
