import 'package:aegis_docs/features/document_prep/providers/image_format_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A card that displays the user-configurable
/// options for image format conversion.
class FormatOptionsCard extends ConsumerWidget {
  /// Creates an instance of [FormatOptionsCard].
  const FormatOptionsCard({
    required this.state,
    required this.notifier,
    required this.isProcessing,
    required this.onSave,
    super.key,
  });

  /// The current state from the [ImageFormatViewModel].
  final ImageFormatState state;

  /// The notifier for the [ImageFormatViewModel].
  final ImageFormatViewModel notifier;

  /// A flag indicating if a conversion or save operation is in progress.
  final bool isProcessing;

  /// A callback function to be invoked when the "Save" button is tapped.
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A list of image formats supported by the image processing library.
    const supportedFormats = [
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
              // Disable the dropdown while processing.
              onChanged: isProcessing
                  ? null
                  : (value) {
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
                  icon: isProcessing
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.transform),
                  label: const Text('Convert'),
                  onPressed: isProcessing ? null : notifier.convertImage,
                ),
                // Only show the save button after a conversion has occurred.
                if (state.convertedImage != null)
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
                    onPressed: isProcessing ? null : onSave,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
