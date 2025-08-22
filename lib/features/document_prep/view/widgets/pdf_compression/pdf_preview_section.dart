import 'package:aegis_docs/features/document_prep/providers/pdf_compression_provider.dart';
import 'package:flutter/material.dart';

class PdfPreviewSection extends StatelessWidget {
  const PdfPreviewSection({required this.state, super.key});
  final PdfCompressionState state;

  String _formatSize(int bytes) => '${(bytes / 1024).toStringAsFixed(2)} KB';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('PDF Preview', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _PdfInfoCard(
                label: 'Original',
                fileName: state.pickedPdf!.name,
                fileSize: _formatSize(state.pickedPdf!.bytes.lengthInBytes),
              ),
            ),
            // This check now works correctly with the updated state.
            if (state.compressedPdfBytes != null) ...[
              const SizedBox(width: 16),
              Expanded(
                child: _PdfInfoCard(
                  label: 'Compressed',
                  fileName: 'compressed_${state.pickedPdf!.name}',
                  fileSize: _formatSize(
                    state.compressedPdfBytes!.lengthInBytes,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _PdfInfoCard extends StatelessWidget {

  const _PdfInfoCard({
    required this.label,
    required this.fileName,
    required this.fileSize,
  });
  final String label;
  final String fileName;
  final String fileSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.picture_as_pdf, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  fileName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(fileSize),
      ],
    );
  }
}
