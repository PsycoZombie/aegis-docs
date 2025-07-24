import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/picked_file_model.dart';
import '../../providers/document_providers.dart';

class TestImageResizeWidget extends ConsumerStatefulWidget {
  const TestImageResizeWidget({super.key});

  @override
  ConsumerState<TestImageResizeWidget> createState() =>
      _TestImageResizeWidgetState();
}

class _TestImageResizeWidgetState extends ConsumerState<TestImageResizeWidget> {
  PickedFile? _originalImage;
  Uint8List? _resizedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    // Reset state when picking a new image
    setState(() {
      _originalImage = null;
      _resizedImage = null;
      _isLoading = true;
    });

    try {
      final image = await ref.read(documentRepositoryProvider).pickImage();
      setState(() {
        _originalImage = image;
      });
    } catch (e) {
      _showError('Error picking image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resizeImage() async {
    if (_originalImage == null) return;

    setState(() => _isLoading = true);
    try {
      final result = await ref
          .read(documentRepositoryProvider)
          .resizeImage(_originalImage!.bytes, width: 300, height: 300);
      setState(() {
        _resizedImage = result;
      });
    } catch (e) {
      _showError('Error resizing image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatSize(int bytes) => '${(bytes / 1024).toStringAsFixed(2)} KB';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isLoading) const CircularProgressIndicator(),

        if (_originalImage == null && !_isLoading)
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text('1. Pick an Image'),
          ),

        if (_originalImage != null) ...[
          const Text(
            'Original Image',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Image.memory(_originalImage!.bytes, height: 150, fit: BoxFit.contain),
          Text('Size: ${_formatSize(_originalImage!.bytes.lengthInBytes)}'),
          const SizedBox(height: 20),

          if (_resizedImage != null) ...[
            const Text(
              'Resized Image',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Image.memory(_resizedImage!, height: 150, fit: BoxFit.contain),
            Text('Size: ${_formatSize(_resizedImage!.lengthInBytes)}'),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(documentRepositoryProvider)
                    .saveEncryptedDocument(
                      data: _resizedImage!,
                      fileName: 'resized_image.jpg',
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Resized image saved!')),
                );
              },
              child: const Text('Save Resized Image'),
            ),
          ] else
            ElevatedButton(
              onPressed: _isLoading ? null : _resizeImage,
              child: const Text('2. Resize Image'),
            ),
        ],
      ],
    );
  }
}
