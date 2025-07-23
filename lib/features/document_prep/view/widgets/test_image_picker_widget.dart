import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/picked_file_model.dart';
import '../../providers/document_providers.dart';

class TestImagePickerWidget extends ConsumerStatefulWidget {
  const TestImagePickerWidget({super.key});

  @override
  ConsumerState<TestImagePickerWidget> createState() =>
      _TestImagePickerWidgetState();
}

class _TestImagePickerWidgetState extends ConsumerState<TestImagePickerWidget> {
  PickedFile? _pickedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    setState(() => _isLoading = true);
    try {
      final image = await ref.read(documentRepositoryProvider).pickImage();
      setState(() {
        _pickedImage = image;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isLoading)
          const CircularProgressIndicator()
        else if (_pickedImage != null) ...[
          const Text(
            'Success!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Image.memory(_pickedImage!.bytes, height: 250, fit: BoxFit.contain),
          const SizedBox(height: 16),
          Text('Name: ${_pickedImage!.name}'),
          Text('Path: ${_pickedImage!.path ?? 'N/A'}'),
          Text(
            'Size: ${(_pickedImage!.bytes.lengthInBytes / 1024).toStringAsFixed(2)} KB',
          ),
          const SizedBox(height: 24),
        ],
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Pick an Image'),
        ),
      ],
    );
  }
}
