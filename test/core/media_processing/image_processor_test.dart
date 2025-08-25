import 'dart:typed_data';

import 'package:aegis_docs/core/media_processing/image_processor.dart';
import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'image_processor_test.mocks.dart';

// We now mock the ImageCropper class directly.
@GenerateMocks([ImageCropper])
// A helper class to create a small, valid dummy image for testing.
class FakeImage {
  static final Uint8List bytes = Uint8List.fromList([
    // A minimal 1x1 transparent PNG.
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ]);
}

// A fake implementation of the PathProviderPlatform.
class FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return '/fake/temp';
  }
}

void main() {
  late ImageProcessor imageProcessor;
  late MockImageCropper mockImageCropper;
  late MemoryFileSystem memoryFileSystem;

  setUp(() {
    PathProviderPlatform.instance = FakePathProvider();
    mockImageCropper = MockImageCropper();
    // Create an in-memory file system for the test.
    memoryFileSystem = MemoryFileSystem();
    // We must create the fake temporary directory in
    // memory before the test runs.
    memoryFileSystem.directory('/fake/temp').createSync(recursive: true);

    // Inject the mock cropper and the in-memory file system into our service.
    imageProcessor = ImageProcessor(
      imageCropper: mockImageCropper,
      fileSystem: memoryFileSystem,
    );
  });

  group('ImageProcessor', () {
    test('compressImage should return a valid JPEG byte list', () async {
      // Act
      final result = await imageProcessor.compressImage(
        imageBytes: FakeImage.bytes,
      );
      // Assert
      expect(result, isA<Uint8List>());
      expect(result, isNotEmpty);
    });

    test('applyGrayscale should return a valid JPEG byte list', () async {
      // Act
      final result = await imageProcessor.applyGrayscale(
        imageBytes: FakeImage.bytes,
      );
      // Assert
      expect(result, isA<Uint8List>());
      expect(result, isNotEmpty);
    });

    test('crop should return bytes when user confirms crop', () async {
      // Arrange
      // Create a fake file in our in-memory file system.
      const fakeCroppedFilePath = '/fake/path/cropped.jpg';
      memoryFileSystem.file(fakeCroppedFilePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(FakeImage.bytes);

      // Configure the mock cropper to return a
      // CroppedFile pointing to our fake file.
      final fakeCroppedFile = CroppedFile(fakeCroppedFilePath);
      when(
        mockImageCropper.cropImage(
          sourcePath: anyNamed('sourcePath'),
          uiSettings: anyNamed('uiSettings'),
        ),
      ).thenAnswer((_) async => fakeCroppedFile);

      // Act
      final result = await imageProcessor.crop(
        imageBytes: FakeImage.bytes,
        theme: ThemeData(),
      );

      // Assert
      expect(result, isNotNull);
      expect(result, equals(FakeImage.bytes));
    });

    test('crop should return null when user cancels crop', () async {
      // Arrange: Configure the mock cropper to return null.
      when(
        mockImageCropper.cropImage(
          sourcePath: anyNamed('sourcePath'),
          uiSettings: anyNamed('uiSettings'),
        ),
      ).thenAnswer((_) async => null);

      // Act
      final result = await imageProcessor.crop(
        imageBytes: FakeImage.bytes,
        theme: ThemeData(),
      );

      // Assert
      expect(result, isNull);
    });
  });
}
