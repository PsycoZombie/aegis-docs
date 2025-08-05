import 'package:aegis_docs/features/document_prep/providers/image_format_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FormatOptionsCard extends ConsumerWidget {
  final ImageFormatState state;
  final ImageFormatViewModel notifier;

  const FormatOptionsCard({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supportedFormats = ['jpg', 'png', 'gif', 'bmp'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Conversion Options",
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
            FilledButton.icon(
              icon: state.isProcessing
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.transform),
              label: Text(
                state.isProcessing ? 'Processing...' : 'Convert & Save',
              ),
              onPressed: state.isProcessing
                  ? null
                  : () async {
                      await notifier.convertAndSaveImage();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Image saved successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
