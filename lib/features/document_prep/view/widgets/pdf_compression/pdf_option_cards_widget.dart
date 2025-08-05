// file: features/document_prep/view/widgets/pdf_compression/pdf_options_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/pdf_compression_provider.dart';

class PdfOptionsCard extends ConsumerWidget {
  final PdfCompressionState state;
  final PdfCompressionViewModel notifier;

  const PdfOptionsCard({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final originalSizeKB = state.pickedPdf!.bytes.lengthInBytes / 1024;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Target Size Limit: ${state.sizeLimitKB} KB',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: state.sizeLimitKB.toDouble(),
              min: 50,
              max: originalSizeKB, // Slider max is the original file size
              label: '${state.sizeLimitKB} KB',
              onChanged: (value) => notifier.setSizeLimit(value.toInt()),
            ),
            SwitchListTile(
              title: const Text('Preserve Text'),
              value: state.preserveText,
              onChanged: notifier.setPreserveText,
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
                  : const Icon(Icons.compress),
              label: Text(
                state.isProcessing ? 'Compressing...' : 'Compress & Save',
              ),
              onPressed: state.isProcessing
                  ? null
                  : () async {
                      final success = await notifier.compressAndSavePdf();
                      if (context.mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('PDF compressed and saved!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Compression failed. Please check the logs.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
