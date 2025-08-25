import 'dart:math';

import 'package:aegis_docs/features/document_prep/providers/image_compression_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A card containing the user-configurable options for image compression.
class CompressionOptionsCard extends ConsumerWidget {
  /// Creates an instance of [CompressionOptionsCard].
  const CompressionOptionsCard({
    required this.state,
    required this.notifier,
    required this.isProcessing,
    required this.onSave,
    super.key,
  });

  /// The current state from the [ImageCompressionViewModel].
  final CompressionState state;

  /// The notifier for the [ImageCompressionViewModel].
  final ImageCompressionViewModel notifier;

  /// A flag indicating if a compression or save operation is in progress.
  final bool isProcessing;

  /// A callback function to be invoked when the "Save" button is tapped.
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Define the min and max for the slider.
    const double minSize = 50;
    final double maxSize = max(
      minSize,
      state.originalImage!.bytes!.lengthInBytes / 1024,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Compression Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),

            // Text display for the current slider value
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Target Size:', style: TextStyle(fontSize: 16)),
                Text(
                  '${state.targetSizeKB} KB',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Slider to control the target compression size
            Slider(
              value: state.targetSizeKB.toDouble().clamp(minSize, maxSize),
              min: minSize,
              max: maxSize, // Steps of 10 KB
              label: '${state.targetSizeKB} KB',
              onChanged: isProcessing
                  ? null // Disable the slider while processing
                  : (double value) {
                      notifier.setTargetSize(value.round());
                    },
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  icon: isProcessing
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.compress),
                  label: const Text('Compress'),
                  onPressed: isProcessing ? null : notifier.compressImage,
                ),
                // Only show the save button after a compression has occurred.
                if (state.compressedImage != null)
                  FilledButton.icon(
                    icon: const Icon(Icons.save_alt_outlined),
                    label: const Text('Save'),
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
