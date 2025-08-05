import 'package:aegis_docs/features/document_prep/providers/image_format_provider.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class FormatImagePreviewSection extends StatelessWidget {
  final ImageFormatState state;
  const FormatImagePreviewSection({super.key, required this.state});

  String _formatSize(int bytes) => '${(bytes / 1024).toStringAsFixed(2)} KB';

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
                child: Column(
                  children: [
                    Text(
                      'Original (${p.extension(state.originalImage!.name)})',
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Image.memory(
                        state.originalImage!.bytes,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_formatSize(state.originalImage!.bytes.lengthInBytes)),
                  ],
                ),
              ),
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
