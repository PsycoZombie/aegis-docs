import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

/// A tuple representing the result of processing a picked file.
typedef ProcessedFileResult = (PickedFileModel?, bool wasConverted);

/// Provides an instance of [FilePickerService] for dependency injection.
final filePickerServiceProvider = Provider<FilePickerService>((ref) {
  return FilePickerService();
});

/// A service that handles file and image selection from the device.
class FilePickerService {
  /// Creates an instance of [FilePickerService].
  FilePickerService({
    ImagePicker? imagePicker,
    FilePicker? filePicker,
  }) : _imagePicker = imagePicker ?? ImagePicker(),
       _filePicker = filePicker ?? FilePicker.platform;

  final ImagePicker _imagePicker;
  final FilePicker _filePicker;

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
      final imageBytes = await file.readAsBytes();
      var finalFileName = file.name;
      var wasConverted = false;
      Uint8List processedBytes;

      if (_decodableFormats.contains(fileExtension)) {
        processedBytes = imageBytes;
      } else {
        debugPrint(
          'Unsupported format "$fileExtension" detected. Converting to JPG...',
        );
        processedBytes = await FlutterImageCompress.compressWithList(
          imageBytes,
          quality: 100,
        );
        finalFileName = '${p.basenameWithoutExtension(file.path)}.jpg';
        wasConverted = true;
      }

      return (
        PickedFileModel(
          bytes: processedBytes,
          name: finalFileName,
          path: file.path,
        ),
        wasConverted,
      );
    } on Object catch (e) {
      debugPrint(
        'Failed to process or convert image format for ${file.name}: $e',
      );
      return (null, false);
    }
  }

  /// Sanitizes an image for PDF embedding.
  Future<PickedFileModel?> _processAndSanitizeFileForPdf(XFile file) async {
    try {
      final originalBytes = await file.readAsBytes();
      final sanitizedBytes = await FlutterImageCompress.compressWithList(
        originalBytes,
      );
      final finalFileName = '${p.basenameWithoutExtension(file.path)}.jpg';
      return PickedFileModel(
        bytes: sanitizedBytes,
        name: finalFileName,
        path: file.path,
      );
    } on Object catch (e) {
      debugPrint('Failed to sanitize image for PDF: $e');
      return null;
    }
  }

  /// Picks a single image from the device gallery.
  Future<ProcessedFileResult> pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        return await _processPickedFile(pickedFile);
      }
    } on Object catch (e) {
      debugPrint('Error picking image: $e');
    }
    return (null, false);
  }

  /// Picks multiple images from the device gallery.
  Future<List<ProcessedFileResult>> pickMultipleImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        return await Future.wait(pickedFiles.map(_processPickedFile));
      }
    } on Object catch (e) {
      debugPrint('Error picking multiple images: $e');
    }
    return [];
  }

  /// Picks a single PDF file from the device.
  Future<PickedFileModel?> pickPdf() async {
    try {
      final result = await _filePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final platformFile = result.files.single;
        return PickedFileModel(
          bytes: platformFile.bytes,
          name: platformFile.name,
          path: platformFile.path,
        );
      }
    } on Object catch (e) {
      debugPrint('Error picking PDF: $e');
    }
    return null;
  }

  /// Picks multiple images and prepares them for PDF conversion.
  Future<List<PickedFileModel>> pickAndSanitizeMultipleImagesForPdf() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        final results = await Future.wait(
          pickedFiles.map(_processAndSanitizeFileForPdf),
        );
        return results.whereType<PickedFileModel>().toList();
      }
    } on Object catch (e) {
      debugPrint('Error picking and sanitizing images for PDF: $e');
    }
    return [];
  }
}
