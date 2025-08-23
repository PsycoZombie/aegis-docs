import 'package:aegis_docs/features/document_prep/providers/pdf_compression_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A card containing the user-configurable options for PDF compression.
class PdfOptionsCard extends ConsumerWidget {
  /// Creates an instance of [PdfOptionsCard].
  const PdfOptionsCard({
    required this.state,
    required this.notifier,
    required this.isProcessing,
    required this.onSave,
    super.key,
  });

  /// The current state from the [PdfCompressionViewModel].
  final PdfCompressionState state;

  /// The notifier for the [PdfCompressionViewModel].
  final PdfCompressionViewModel notifier;

  /// A flag indicating if the compression operation is currently in progress.
  final bool isProcessing;

  /// A callback function to be invoked when the
  /// "Compress & Save" button is tapped.
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final originalSizeKB = state.pickedPdf!.bytes!.lengthInBytes / 1024;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Target Size Limit: ${state.sizeLimitKB} KB',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: state.sizeLimitKB.toDouble(),
              min: 50,
              // The max value of the slider should
              // not exceed the original file size.
              max: originalSizeKB < 50 ? 50 : originalSizeKB,
              label: '${state.sizeLimitKB} KB',
              onChanged: (value) => notifier.setSizeLimit(value.toInt()),
            ),
            SwitchListTile(
              title: const Text('Preserve Text'),
              subtitle: const Text('May result in a larger file size'),
              value: state.preserveText,
              onChanged: (val) => notifier.setPreserveText(value: val),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: isProcessing
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.compress),
              label: Text(
                isProcessing ? 'Processing...' : 'Compress & Save',
              ),
              // Disable the button while an operation is in progress.
              onPressed: isProcessing ? null : onSave,
            ),
          ],
        ),
      ),
    );
  }
}
