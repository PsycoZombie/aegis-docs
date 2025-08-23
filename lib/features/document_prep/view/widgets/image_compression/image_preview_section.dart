import 'dart:typed_data';

import 'package:aegis_docs/features/document_prep/providers/image_compression_provider.dart';
import 'package:aegis_docs/shared_widgets/full_screen_image_view.dart';
import 'package:flutter/material.dart';

/// A widget that displays a side-by-side preview of the original image and
/// the compressed image, along with their file sizes.
class CompressionImagePreviewSection extends StatelessWidget {
  /// Creates an instance of [CompressionImagePreviewSection].
  const CompressionImagePreviewSection({required this.state, super.key});

  /// The current state from the [ImageCompressionViewModel].
  final CompressionState state;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Text('Image Preview', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        // Constrain the height of the preview section to
        // avoid overflowing on smaller screens.
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Original Image Preview --- //
              Expanded(
                child: _ImagePreview(
                  label: 'Original',
                  imageBytes: state.originalImage!.bytes!,
                  sizeInBytes: state.originalImage!.bytes!.lengthInBytes,
                ),
              ),
              // --- Compressed Image Preview (conditional) --- //
              if (state.compressedImage != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _ImagePreview(
                    label: 'Compressed',
                    imageBytes: state.compressedImage!,
                    sizeInBytes: state.compressedSize!,
                  ),
                ),
              ],
            ],
          ),
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
    required this.sizeInBytes,
  });

  /// The title for the preview (e.g., "Original" or "Compressed").
  final String label;

  /// The image data to display.
  final Uint8List imageBytes;

  /// The size of the image in bytes.
  final int sizeInBytes;

  /// A helper function to format a file size in
  ///  bytes into a readable KB string.
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
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: Hero(
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
          ),
          const SizedBox(height: 8),
          Text(_formatSize(sizeInBytes)),
        ],
      ),
    );
  }
}
