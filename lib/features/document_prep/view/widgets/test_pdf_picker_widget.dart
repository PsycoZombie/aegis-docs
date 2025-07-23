import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/picked_file_model.dart';
import '../../providers/document_providers.dart';

class TestPdfPickerWidget extends ConsumerStatefulWidget {
  const TestPdfPickerWidget({super.key});

  @override
  ConsumerState<TestPdfPickerWidget> createState() =>
      _TestPdfPickerWidgetState();
}

class _TestPdfPickerWidgetState extends ConsumerState<TestPdfPickerWidget> {
  PickedFile? _pickedPdf;
  bool _isLoading = false;

  Future<void> _pickPdf() async {
    setState(() => _isLoading = true);
    try {
      final pdf = await ref.read(documentRepositoryProvider).pickPdf();
      setState(() {
        _pickedPdf = pdf;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking PDF: $e')));
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
        else if (_pickedPdf != null) ...[
          const Text(
            'Success!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          const Icon(Icons.picture_as_pdf, color: Colors.red, size: 100),
          const SizedBox(height: 16),
          Text('Name: ${_pickedPdf!.name}'),
          Text('Path: ${_pickedPdf!.path ?? 'N/A'}'),
          Text(
            'Size: ${(_pickedPdf!.bytes.lengthInBytes / 1024).toStringAsFixed(2)} KB',
          ),
          const SizedBox(height: 24),
        ],
        ElevatedButton(onPressed: _pickPdf, child: const Text('Pick a PDF')),
      ],
    );
  }
}
