import 'package:aegis_docs/features/document_prep/providers/images_to_pdf_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A card that displays the action buttons for the "Images to PDF" feature,
/// such as "Convert to PDF" and "Save".
class ImagesToPdfOptionsCard extends ConsumerWidget {
  /// Creates an instance of [ImagesToPdfOptionsCard].
  const ImagesToPdfOptionsCard({
    required this.state,
    required this.notifier,
    required this.isProcessing,
    required this.onSave,
    super.key,
  });

  /// The current state from the [ImagesToPdfViewModel].
  final ImagesToPdfState state;

  /// The notifier for the [ImagesToPdfViewModel].
  final ImagesToPdfViewModel notifier;

  /// A flag indicating if a conversion or save operation is in progress.
  final bool isProcessing;

  /// A callback function to be invoked when the "Save" button is tapped.
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton.icon(
              icon: isProcessing
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.transform),
              label: Text(
                isProcessing ? 'Converting...' : 'Convert to PDF',
              ),
              // Disable the button while an operation is in progress.
              onPressed: isProcessing ? null : notifier.convertToPdf,
            ),
            // Only show the save button after a PDF has been generated.
            if (state.generatedPdf != null)
              FilledButton.icon(
                icon: isProcessing
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_alt_outlined),
                label: Text(isProcessing ? 'Saving...' : 'Save'),
                // Disable the button while an operation is in progress.
                onPressed: isProcessing ? null : onSave,
              ),
          ],
        ),
      ),
    );
  }
}
