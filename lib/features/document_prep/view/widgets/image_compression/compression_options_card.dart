import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../features/document_prep/providers/image_compression_provider.dart';

class CompressionOptionsCard extends ConsumerWidget {
  final CompressionState state;
  final ImageCompressionViewModel notifier;

  const CompressionOptionsCard({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetSizeController = TextEditingController(
      text: state.targetSizeKB.toString(),
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Compression Options",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 120,
              child: TextFormField(
                controller: targetSizeController,
                decoration: const InputDecoration(
                  labelText: 'Target Size',
                  suffixText: 'KB',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (value) {
                  final size = int.tryParse(value);
                  if (size != null) {
                    notifier.setTargetSize(size);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  icon: const Icon(Icons.compress),
                  label: const Text('Compress'),
                  onPressed: () => notifier.compressImage(),
                ),
                if (state.compressedImage != null)
                  FilledButton.icon(
                    icon: const Icon(Icons.save_alt_outlined),
                    label: const Text('Save'),
                    onPressed: () async {
                      await notifier.saveCompressedImage();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Image saved successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
