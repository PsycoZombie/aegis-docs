import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/picked_file_model.dart';
import '../../providers/document_providers.dart';

class TestImageToPdfWidget extends ConsumerStatefulWidget {
  const TestImageToPdfWidget({super.key});

  @override
  ConsumerState<TestImageToPdfWidget> createState() =>
      _TestImageToPdfWidgetState();
}

class _TestImageToPdfWidgetState extends ConsumerState<TestImageToPdfWidget> {
  PickedFile? _originalImage;
  Uint8List? _generatedPdf;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    setState(() {
      _originalImage = null;
      _generatedPdf = null;
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

  Future<void> _convertToPdf() async {
    if (_originalImage == null) return;

    setState(() => _isLoading = true);
    try {
      final result = await ref
          .read(documentRepositoryProvider)
          .convertImageToPdf(_originalImage!.bytes);
      setState(() {
        _generatedPdf = result;
      });
    } catch (e) {
      _showError('Error converting to PDF: $e');
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
            'Selected Image',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Image.memory(_originalImage!.bytes, height: 200, fit: BoxFit.contain),
          const SizedBox(height: 20),

          if (_generatedPdf != null) ...[
            const Icon(Icons.check_circle, color: Colors.green, size: 50),
            const SizedBox(height: 8),
            const Text(
              'PDF Generated Successfully!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('PDF Size: ${_formatSize(_generatedPdf!.lengthInBytes)}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(documentRepositoryProvider)
                    .saveDocument(
                      _generatedPdf!,
                      fileName: 'converted_from_image.pdf',
                    );
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('PDF saved!')));
              },
              child: const Text('Save PDF'),
            ),
          ],

          ElevatedButton(
            onPressed: _isLoading ? null : _convertToPdf,
            child: const Text('2. Convert to PDF'),
          ),
        ],
      ],
    );
  }
}
