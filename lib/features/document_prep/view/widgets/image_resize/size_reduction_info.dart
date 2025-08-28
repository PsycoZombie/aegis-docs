import 'package:aegis_docs/features/document_prep/providers/image_resize_provider.dart';
import 'package:flutter/material.dart';

/// A widget that displays the percentage of file size reduction after an
/// image has been resized.
class SizeReductionInfo extends StatelessWidget {
  /// Creates an instance of [SizeReductionInfo].
  const SizeReductionInfo({required this.state, super.key});

  /// The current state from the [ImageResizeViewModel].
  final ResizeState state;

  @override
  Widget build(BuildContext context) {
    final hasResized = state.resizedImage != null;
    // If no resize has occurred yet, render nothing.
    if (!hasResized) return const SizedBox.shrink();
    final theme = Theme.of(context);

    final originalSize = state.originalImage!.bytes!.lengthInBytes;
    final resizedSize = state.resizedImage!.lengthInBytes;
    final reduction = (originalSize - resizedSize) / originalSize * 100;

    // Display a message indicating the percentage of size reduction.
    if (reduction > 0.1) {
      return Text(
        '✨ File size reduced by ${reduction.toStringAsFixed(1)}%',
        style: theme.textTheme.bodyLarge!.copyWith(
          color: Colors.green.shade700,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    // Handle the edge case where the file size might increase.
    else if (reduction < -0.1) {
      return Text(
        '⚠️ File size increased by ${(-reduction).toStringAsFixed(1)}%',
        style: theme.textTheme.bodyLarge!.copyWith(
          color: Colors.orange.shade700,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    // If the change is negligible, render nothing.
    else {
      return const SizedBox.shrink();
    }
  }
}
