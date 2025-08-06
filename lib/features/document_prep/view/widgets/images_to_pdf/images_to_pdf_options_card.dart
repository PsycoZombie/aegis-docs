import 'package:aegis_docs/features/document_prep/providers/images_to_pdf_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImagesToPdfOptionsCard extends ConsumerWidget {
  final ImagesToPdfState state;
  final ImagesToPdfViewModel notifier;
  final VoidCallback onSave;

  const ImagesToPdfOptionsCard({
    super.key,
    required this.state,
    required this.notifier,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton.icon(
              icon: state.isProcessing
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.transform),
              label: Text(
                state.isProcessing ? 'Converting...' : 'Convert to PDF',
              ),
              onPressed: state.isProcessing ? null : notifier.convertToPdf,
            ),
            if (state.generatedPdf != null)
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
      ),
    );
  }
}
