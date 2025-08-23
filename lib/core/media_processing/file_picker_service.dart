import 'dart:io';

import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

/// A tuple representing the result of processing a picked file.
///
/// The first element is the [PickedFileModel] itself, which may be null if
/// processing fails. The second is a boolean indicating whether the file
/// was converted from an unsupported format to a supported one.
typedef ProcessedFileResult = (PickedFileModel?, bool wasConverted);

/// Provides an instance of [FilePickerService] for dependency injection.
final filePickerServiceProvider = Provider<FilePickerService>((ref) {
  return FilePickerService();
});

/// A service that handles file and image selection from the device.
///
/// This class abstracts the functionality of `image_picker` and `file_picker`,
/// providing a unified interface for picking images and PDFs. It also includes
/// logic to handle and convert unsupported image formats to ensure they can be
/// processed by the application.
class FilePickerService {
  final ImagePicker _imagePicker = ImagePicker();
  final FilePicker _filePicker = FilePicker.platform;

  /// A set of image file extensions that the `image` package can decode.
  static const Set<String> _decodableFormats = {
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.ico',
    '.tiff',
    '.tga',
    '.psd',
    '.pvr',
    '.exr',
    '.pnm',
  };

  /// Processes a picked image file, converting it if necessary.
  Future<ProcessedFileResult> _processPickedFile(XFile file) async {
    try {
      final fileExtension = p.extension(file.path).toLowerCase();
      Uint8List imageBytes;
      var finalFileName = file.name;
      var wasConverted = false;

      if (_decodableFormats.contains(fileExtension)) {
        imageBytes = await file.readAsBytes();
      } else {
        // If the format is not supported by the
        // image library, convert it to JPG.
        debugPrint(
          'Unsupported format "$fileExtension" detected. Converting to JPG...',
        );
        final originalBytes = await file.readAsBytes();
        imageBytes = await FlutterImageCompress.compressWithList(
          originalBytes,
          quality: 100, // Use high quality for conversion
        );
        finalFileName = '${p.basenameWithoutExtension(file.path)}.jpg';
        wasConverted = true;
      }

      return (
        PickedFileModel(
          bytes: imageBytes,
          name: finalFileName,
          path: file.path,
        ),
        wasConverted,
      );
    } on Exception catch (e) {
      debugPrint(
        'Failed to process or convert image format for ${file.name}: $e',
      );
      return (null, false);
    }
  }

  /// Sanitizes an image for PDF embedding by
  /// converting it to a standard format.
  Future<PickedFileModel?> _processAndSanitizeFileForPdf(XFile file) async {
    try {
      final originalBytes = await file.readAsBytes();
      // Compress with default settings to standardize the image.
      final sanitizedBytes = await FlutterImageCompress.compressWithList(
        originalBytes,
      );
      final finalFileName = '${p.basenameWithoutExtension(file.path)}.jpg';
      return PickedFileModel(
        bytes: sanitizedBytes,
        name: finalFileName,
        path: file.path,
      );
    } on Exception catch (e) {
      debugPrint('Failed to sanitize image for PDF: $e');
      return null;
    }
  }

  /// Picks a single image from the device gallery.
  ///
  /// After picking, it processes the image to ensure it's in a usable format,
  /// converting it if necessary. Returns a [ProcessedFileResult].
  Future<ProcessedFileResult> pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        return await _processPickedFile(pickedFile);
      }
    } on Exception catch (e) {
      debugPrint('Error picking image: $e');
    }
    return (null, false);
  }

  /// Picks multiple images from the device gallery.
  ///
  /// Each selected image is processed concurrently.
  /// Returns a list of [ProcessedFileResult].
  Future<List<ProcessedFileResult>> pickMultipleImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        return await Future.wait(pickedFiles.map(_processPickedFile));
      }
    } on Exception catch (e) {
      debugPrint('Error picking multiple images: $e');
    }
    return [];
  }

  /// Picks a single PDF file from the device.
  ///
  /// Returns a [PickedFileModel] containing the
  /// PDF data, or null if the user cancels.
  Future<PickedFileModel?> pickPdf() async {
    try {
      final result = await _filePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final platformFile = result.files.single;
        final file = File(platformFile.path!);
        final bytes = await file.readAsBytes();

        return PickedFileModel(
          bytes: bytes,
          name: platformFile.name,
          path: platformFile.path,
        );
      }
    } on Exception catch (e) {
      debugPrint('Error picking PDF: $e');
    }
    return null;
  }

  /// Picks multiple images and prepares them for PDF conversion.
  ///
  /// This method ensures all selected images are in a format suitable
  /// for embedding in a PDF by standardizing them.
  Future<List<PickedFileModel>> pickAndSanitizeMultipleImagesForPdf() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        final results = await Future.wait(
          pickedFiles.map(_processAndSanitizeFileForPdf),
        );
        // Filter out any files that failed to process.
        return results.whereType<PickedFileModel>().toList();
      }
    } on Exception catch (e) {
      debugPrint('Error picking and sanitizing images for PDF: $e');
    }
    return [];
  }
}
