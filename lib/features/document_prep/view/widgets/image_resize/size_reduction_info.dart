import 'package:aegis_docs/features/document_prep/providers/image_resize_provider.dart';
import 'package:flutter/material.dart';

class SizeReductionInfo extends StatelessWidget {
  final ResizeState state;
  const SizeReductionInfo({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final hasResized = state.resizedImage != null;
    if (!hasResized) return const SizedBox.shrink();

    final originalSize = state.originalImage!.bytes.lengthInBytes;
    final resizedSize = state.resizedImage!.lengthInBytes;
    final reduction = ((originalSize - resizedSize) / originalSize * 100);

    return Text(
      reduction > 0
          ? '✨ File size reduced by ${reduction.toStringAsFixed(1)}%'
          : '',
      style: TextStyle(
        color: Colors.green.shade700,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}
