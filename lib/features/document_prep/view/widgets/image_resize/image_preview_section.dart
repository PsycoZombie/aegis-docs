import 'dart:typed_data';

import 'package:aegis_docs/features/document_prep/providers/image_resize_provider.dart';
import 'package:aegis_docs/shared_widgets/full_screen_image_view.dart';
import 'package:flutter/material.dart';

/// A widget that displays a side-by-side comparison of the original image
/// and the resized image.
class ImagePreviewSection extends StatelessWidget {
  /// Creates an instance of [ImagePreviewSection].
  const ImagePreviewSection({required this.state, super.key});

  /// The current state from the [ImageResizeViewModel].
  final ResizeState state;

  @override
  Widget build(BuildContext context) {
    final hasResized = state.resizedImage != null;
    return Column(
      children: [
        Text('Image Preview', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ImagePreview(
                label: 'Original',
                imageBytes: state.originalImage!.bytes!,
                dimensions: state.originalDimensions,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                // Show the resized preview only after a resize has occurred.
                child: hasResized
                    ? _ImagePreview(
                        label: 'Resized',
                        imageBytes: state.resizedImage!,
                      )
                    : const SizedBox(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A private helper widget to display a single image preview with its details.
class _ImagePreview extends StatelessWidget {
  /// Creates an instance of [_ImagePreview].
  const _ImagePreview({
    required this.label,
    required this.imageBytes,
    this.dimensions,
  });

  /// The title for the preview (e.g., "Original" or "Resized").
  final String label;

  /// The image data to display.
  final Uint8List imageBytes;

  /// The width and height of the image, if available.
  final Size? dimensions;

  /// A helper function to format a file size
  /// in bytes into a readable KB string.
  String _formatSize(int bytes) => '${(bytes / 1024).toStringAsFixed(2)} KB';

  @override
  Widget build(BuildContext context) {
    // A unique tag for the Hero animation.
    final heroTag = '$label-${imageBytes.hashCode}';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<dynamic>(
            builder: (_) =>
                FullScreenImageView(imageBytes: imageBytes, heroTag: heroTag),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Hero(
            tag: heroTag,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                imageBytes,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(_formatSize(imageBytes.lengthInBytes)),
          if (dimensions != null)
            Text(
              '${dimensions!.width.toInt()} x ${dimensions!.height.toInt()}',
            ),
        ],
      ),
    );
  }
}
