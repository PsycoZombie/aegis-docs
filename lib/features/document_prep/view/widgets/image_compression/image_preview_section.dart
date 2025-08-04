import 'dart:typed_data';

import 'package:aegis_docs/shared_widgets/full_screen_image_view.dart';
import 'package:flutter/material.dart';

import '../../../../../../features/document_prep/providers/image_compression_provider.dart';

class CompressionImagePreviewSection extends StatelessWidget {
  final CompressionState state;
  const CompressionImagePreviewSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Text("Image Preview", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ImagePreview(
                  label: 'Original',
                  imageBytes: state.originalImage!,
                  sizeInBytes: state.originalSize!,
                ),
              ),
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

class _ImagePreview extends StatelessWidget {
  final String label;
  final Uint8List imageBytes;
  final int sizeInBytes;

  const _ImagePreview({
    required this.label,
    required this.imageBytes,
    required this.sizeInBytes,
  });

  String _formatSize(int bytes) => '${(bytes / 1024).toStringAsFixed(2)} KB';

  @override
  Widget build(BuildContext context) {
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
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: Hero(
              tag: heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
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
