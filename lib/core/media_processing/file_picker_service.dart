import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart' hide PickedFile;
import 'package:path/path.dart' as p;

import '../../data/models/picked_file_model.dart';

class FilePickerService {
  final ImagePicker _imagePicker = ImagePicker();
  final FilePicker _filePicker = FilePicker.platform;

  Future<PickedFile?> _processPickedFile(XFile file) async {
    try {
      final originalBytes = await file.readAsBytes();
      final sanitizedBytes = await FlutterImageCompress.compressWithList(
        originalBytes,
        format: CompressFormat.jpeg,
        quality: 100,
      );

      final finalFileName = '${p.basenameWithoutExtension(file.path)}.jpg';

      return PickedFile(
        bytes: sanitizedBytes,
        name: finalFileName,
        path: file.path,
      );
    } catch (_) {
      return null;
    }
  }

  Future<PickedFile?> pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        return await _processPickedFile(pickedFile);
      }
    } catch (_) {}
    return null;
  }

  Future<List<PickedFile>> pickMultipleImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        final processedFiles = <PickedFile>[];
        for (final file in pickedFiles) {
          final processed = await _processPickedFile(file);
          if (processed != null) {
            processedFiles.add(processed);
          }
        }
        return processedFiles;
      }
    } catch (_) {}
    return [];
  }

  Future<PickedFile?> pickPdf() async {
    try {
      final FilePickerResult? result = await _filePicker.pickFiles(
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
    } catch (_) {}
    return null;
  }
}
