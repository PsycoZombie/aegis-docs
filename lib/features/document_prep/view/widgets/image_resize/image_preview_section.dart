import 'dart:typed_data';

import 'package:aegis_docs/features/document_prep/providers/resize_tool_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_resize/full_screen_image_view.dart';
import 'package:flutter/material.dart';

class ImagePreviewSection extends StatelessWidget {
  final ResizeState state;
  const ImagePreviewSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final hasResized = state.resizedImage != null;
    return Column(
      children: [
        Text("Image Preview", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        // THE FIX for larger previews: Use a Row with Expanded widgets.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ImagePreview(
                label: 'Original',
                imageBytes: state.originalImage!,
                dimensions: state.originalDimensions,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: hasResized
                    ? _ImagePreview(
                        label: 'Resized',
                        imageBytes: state.resizedImage!,
                      )
                    : const SizedBox(), // Empty space if no resized image
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.label,
    required this.imageBytes,
    this.dimensions,
  });

  final String label;
  final Uint8List imageBytes;
  final Size? dimensions;

  String _formatSize(int bytes) => '${(bytes / 1024).toStringAsFixed(2)} KB';

  @override
  Widget build(BuildContext context) {
    // THE FIX for Hero animation: Wrap with GestureDetector and Hero.
    // A unique tag is created for the animation.
    final heroTag = '$label-${imageBytes.hashCode}';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
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
                // Make the image expand horizontally
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
