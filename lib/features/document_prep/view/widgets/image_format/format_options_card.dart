import 'package:aegis_docs/features/document_prep/providers/image_format_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FormatOptionsCard extends ConsumerWidget {
  const FormatOptionsCard({
    required this.state,
    required this.notifier,
    required this.onSave,
    super.key,
  });
  final ImageFormatState state;
  final ImageFormatViewModel notifier;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supportedFormats = [
      'jpg',
      'png',
      'gif',
      'bmp',
      'ico',
      'tiff',
      'tga',
      'pvr',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Conversion Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: state.targetFormat,
              decoration: const InputDecoration(
                labelText: 'Target Format',
                border: OutlineInputBorder(),
              ),
              items: supportedFormats.map((format) {
                return DropdownMenuItem(
                  value: format,
                  child: Text(format.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  notifier.setTargetFormat(value);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.transform),
                  label: const Text('Convert'),
                  onPressed: state.isProcessing ? null : notifier.convertImage,
                ),
                if (state.convertedImage != null)
                  FilledButton.icon(
                    icon: state.isProcessing
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_alt_outlined),
                    label: Text(state.isProcessing ? 'Saving...' : 'Save'),
                    onPressed: state.isProcessing ? null : onSave,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
