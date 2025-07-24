import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/picked_file_model.dart';
import '../../providers/document_providers.dart';

class TestImageFormatWidget extends ConsumerStatefulWidget {
  const TestImageFormatWidget({super.key});

  @override
  ConsumerState<TestImageFormatWidget> createState() =>
      _TestImageFormatWidgetState();
}

class _TestImageFormatWidgetState extends ConsumerState<TestImageFormatWidget> {
  PickedFile? _originalImage;
  Uint8List? _convertedImage;
  bool _isLoading = false;
  String _selectedFormat = 'jpg';

  Future<void> _pickImage() async {
    setState(() {
      _originalImage = null;
      _convertedImage = null;
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

  Future<void> _changeFormat() async {
    if (_originalImage == null) return;

    setState(() => _isLoading = true);
    try {
      final result = await ref
          .read(documentRepositoryProvider)
          .changeImageFormat(_originalImage!.bytes, format: _selectedFormat);
      setState(() {
        _convertedImage = result;
      });
    } catch (e) {
      _showError('Error changing format: $e');
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

          if (_convertedImage != null) ...[
            Text(
              'Converted Image (${_selectedFormat.toUpperCase()})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Image.memory(_convertedImage!, height: 150, fit: BoxFit.contain),
            Text('Size: ${_formatSize(_convertedImage!.lengthInBytes)}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(documentRepositoryProvider)
                    .saveEncryptedDocument(
                      data: _convertedImage!,
                      fileName: 'formatted_image.$_selectedFormat',
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Formatted image saved!')),
                );
              },
              child: const Text('Save Formatted Image'),
            ),
          ],

          DropdownButton<String>(
            value: _selectedFormat,
            items: ['jpg', 'png'].map((format) {
              return DropdownMenuItem(
                value: format,
                child: Text(format.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedFormat = value);
              }
            },
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _changeFormat,
            child: const Text('2. Change Format'),
          ),
        ],
      ],
    );
  }
}
