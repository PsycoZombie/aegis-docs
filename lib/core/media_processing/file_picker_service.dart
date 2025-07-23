import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart' hide PickedFile;

import '../../data/models/picked_file_model.dart';

class FilePickerService {
  final ImagePicker _imagePicker = ImagePicker();
  final FilePicker _filePicker = FilePicker.platform;

  Future<PickedFile?> pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        return PickedFile(
          bytes: bytes,
          name: pickedFile.name,
          path: pickedFile.path,
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    return null;
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
    } catch (e) {
      debugPrint('Error picking PDF: $e');
    }
    return null;
  }
}
