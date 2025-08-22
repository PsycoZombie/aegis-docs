import 'dart:io';
import 'dart:typed_data';

import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart' hide PickedFile;
import 'package:path/path.dart' as p;

typedef ProcessedFileResult = (PickedFile?, bool wasConverted);

class FilePickerService {
  final ImagePicker _imagePicker = ImagePicker();
  final FilePicker _filePicker = FilePicker.platform;

  Future<ProcessedFileResult> _processPickedFile(XFile file) async {
    try {
      final fileExtension = p.extension(file.path).toLowerCase();
      Uint8List imageBytes;
      var finalFileName = file.name;
      var wasConverted = false;

      const decodableFormats = [
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
      ];

      if (decodableFormats.contains(fileExtension)) {
        imageBytes = await file.readAsBytes();
      } else {
        debugPrint(
          'Unsupported format "$fileExtension" detected. Converting to JPG...',
        );
        final originalBytes = await file.readAsBytes();
        imageBytes = await FlutterImageCompress.compressWithList(
          originalBytes,
          quality: 100,
        );
        finalFileName = '${p.basenameWithoutExtension(file.path)}.jpg';
        wasConverted = true;
      }

      return (
        PickedFile(bytes: imageBytes, name: finalFileName, path: file.path),
        wasConverted,
      );
    } on Exception catch (e) {
      debugPrint(
        'Failed to process or convert image format for ${file.name}: $e',
      );
      return (null, false);
    }
  }

  Future<PickedFile?> _processAndSanitizeFileForPdf(XFile file) async {
    try {
      final originalBytes = await file.readAsBytes();
      final sanitizedBytes = await FlutterImageCompress.compressWithList(
        originalBytes,
      );
      final finalFileName = '${p.basenameWithoutExtension(file.path)}.jpg';
      return PickedFile(
        bytes: sanitizedBytes,
        name: finalFileName,
        path: file.path,
      );
    } on Exception catch (e) {
      debugPrint('Failed to sanitize image for PDF: $e');
      return null;
    }
  }

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

  Future<PickedFile?> pickPdf() async {
    try {
      final result = await _filePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.single.path != null) {
        final platformFile = result.files.single;
        final file = File(platformFile.path!);
        final bytes = await file.readAsBytes();

        return PickedFile(
          bytes: bytes,
          name: platformFile.name,
          path: platformFile.path,
        );
      }
    } on Exception catch (_) {}
    return null;
  }

  Future<List<PickedFile>> pickAndSanitizeMultipleImagesForPdf() async {
    final pickedFiles = await _imagePicker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      final results = await Future.wait(
        pickedFiles.map(_processAndSanitizeFileForPdf),
      );
      return results.whereType<PickedFile>().toList();
    }
    return [];
  }
}
