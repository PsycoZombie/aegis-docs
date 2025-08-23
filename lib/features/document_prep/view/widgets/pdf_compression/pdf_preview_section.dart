import 'package:aegis_docs/features/document_prep/providers/pdf_compression_provider.dart';
import 'package:flutter/material.dart';

/// A widget that displays a side-by-side comparison of the original PDF
/// and the compressed PDF, showing their file names and sizes.
class PdfPreviewSection extends StatelessWidget {
  /// Creates an instance of [PdfPreviewSection].
  const PdfPreviewSection({required this.state, super.key});

  /// The current state from the [PdfCompressionViewModel].
  final PdfCompressionState state;

  /// A helper function to format a file size
  /// in bytes into a readable KB string.
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
                fileSize: _formatSize(state.pickedPdf!.bytes!.lengthInBytes),
              ),
            ),
            // Conditionally display the compressed info card only after
            // a compression operation has been successful.
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

/// A private helper widget to display the information for a single PDF file.
class _PdfInfoCard extends StatelessWidget {
  /// Creates an instance of [_PdfInfoCard].
  const _PdfInfoCard({
    required this.label,
    required this.fileName,
    required this.fileSize,
  });

  /// The title for the card (e.g., "Original" or "Compressed").
  final String label;

  /// The name of the PDF file.
  final String fileName;

  /// The formatted size of the PDF file.
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
