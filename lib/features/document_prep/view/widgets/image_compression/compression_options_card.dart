import 'package:aegis_docs/features/document_prep/providers/image_compression_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A card containing the user-configurable options for image compression.
class CompressionOptionsCard extends ConsumerStatefulWidget {
  /// Creates an instance of [CompressionOptionsCard].
  const CompressionOptionsCard({
    required this.state,
    required this.notifier,
    required this.isProcessing,
    required this.onSave,
    super.key,
  });

  /// The current state from the [ImageCompressionViewModel].
  final CompressionState state;

  /// The notifier for the [ImageCompressionViewModel].
  final ImageCompressionViewModel notifier;

  /// A flag indicating if a compression or save operation is in progress.
  final bool isProcessing;

  /// A callback function to be invoked when the "Save" button is tapped.
  final VoidCallback onSave;

  @override
  ConsumerState<CompressionOptionsCard> createState() =>
      _CompressionOptionsCardState();
}

class _CompressionOptionsCardState
    extends ConsumerState<CompressionOptionsCard> {
  late final TextEditingController _targetSizeController;

  @override
  void initState() {
    super.initState();
    _targetSizeController = TextEditingController(
      text: widget.state.targetSizeKB.toString(),
    );
  }

  @override
  void didUpdateWidget(CompressionOptionsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync the controller's text if the state from the provider changes,
    // for example, when a new image is loaded.
    if (widget.state.targetSizeKB.toString() != _targetSizeController.text) {
      _targetSizeController.text = widget.state.targetSizeKB.toString();
    }
  }

  @override
  void dispose() {
    _targetSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Compression Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 120,
              child: TextFormField(
                controller: _targetSizeController,
                enabled: !widget.isProcessing,
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
                    widget.notifier.setTargetSize(size);
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
                  icon: widget.isProcessing
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.compress),
                  label: const Text('Compress'),
                  onPressed: widget.isProcessing
                      ? null
                      : widget.notifier.compressImage,
                ),
                // Only show the save button after a compression has occurred.
                if (widget.state.compressedImage != null)
                  FilledButton.icon(
                    icon: const Icon(Icons.save_alt_outlined),
                    label: const Text('Save'),
                    onPressed: widget.isProcessing ? null : widget.onSave,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
