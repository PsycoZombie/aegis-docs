import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/document_providers.dart';

class TestNativeCompressionWidget extends ConsumerStatefulWidget {
  const TestNativeCompressionWidget({super.key});

  @override
  ConsumerState<TestNativeCompressionWidget> createState() =>
      _TestNativeCompressionWidgetState();
}

class _TestNativeCompressionWidgetState
    extends ConsumerState<TestNativeCompressionWidget> {
  String? _resultPath;
  bool _isLoading = false;
  double _sizeLimit = 500; // Default size limit in KB
  bool _preserveText = true;

  Future<void> _compressPdf() async {
    setState(() {
      _isLoading = true;
      _resultPath = null;
    });
    try {
      final path = await ref
          .read(documentRepositoryProvider)
          .compressPdfWithNative(
            sizeLimit: _sizeLimit.toInt(),
            preserveText: _preserveText,
          );
      setState(() {
        _resultPath = path;
      });
    } catch (e) {
      _showError('Error compressing PDF: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'This calls the native Kotlin code via a MethodChannel to compress a PDF.',
          textAlign: TextAlign.center,
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // --- Configuration UI ---
        Text(
          'Target Size Limit: ${_sizeLimit.toInt()} KB',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _sizeLimit,
          min: 50,
          max: 2000,
          divisions: 39,
          label: '${_sizeLimit.toInt()} KB',
          onChanged: (value) {
            setState(() {
              _sizeLimit = value;
            });
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text(
            'Preserve Text & Vectors',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          value: _preserveText,
          onChanged: (value) {
            setState(() {
              _preserveText = value;
            });
          },
        ),
        const SizedBox(height: 24),

        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: _compressPdf,
            child: const Text('Pick and Compress PDF'),
          ),

        if (_resultPath != null) ...[
          const SizedBox(height: 24),
          const Text(
            'Result:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Text(
              _resultPath!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ],
    );
  }
}
