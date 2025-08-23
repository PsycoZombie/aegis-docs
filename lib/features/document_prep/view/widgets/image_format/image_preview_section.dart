import 'package:aegis_docs/features/document_prep/providers/image_format_provider.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

/// A widget that displays a side-by-side preview of the original image and
/// the format-converted image.
class FormatImagePreviewSection extends StatelessWidget {
  /// Creates an instance of [FormatImagePreviewSection].
  const FormatImagePreviewSection({required this.state, super.key});

  /// The current state from the [ImageFormatViewModel].
  final ImageFormatState state;

  /// A helper function to format a file size in
  /// bytes into a readable KB string.
  String _formatSize(int bytes) => '${(bytes / 1024).toStringAsFixed(2)} KB';

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
                child: Column(
                  children: [
                    Text(
                      'Original :'
                      '${p.extension(state.originalImage!.name).toUpperCase()}',
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Image.memory(
                        state.originalImage!.bytes!,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatSize(state.originalImage!.bytes!.lengthInBytes),
                    ),
                  ],
                ),
              ),
              // --- Converted Image Preview (conditional) --- //
              if (state.convertedImage != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Text('Converted (${state.targetFormat.toUpperCase()})'),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Image.memory(
                          state.convertedImage!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_formatSize(state.convertedImage!.lengthInBytes)),
                    ],
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
