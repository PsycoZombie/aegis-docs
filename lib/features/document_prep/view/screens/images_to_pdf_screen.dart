import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/images_to_pdf_provider.dart';
import '../widgets/images_to_pdf/reorderable_image_grid.dart';

class ImagesToPdfScreen extends ConsumerWidget {
  const ImagesToPdfScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(imagesToPdfViewModelProvider);
    final notifier = ref.read(imagesToPdfViewModelProvider.notifier);

    return AppScaffold(
      title: 'Images to PDF',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: viewModel.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('An error occurred: $err')),
          data: (state) {
            if (state.selectedImages.isEmpty) {
              return Center(
                child: FilledButton.icon(
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Select Images'),
                  onPressed: () => notifier.pickImages(),
                ),
              );
            }
            return _buildContent(context, state, notifier);
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ImagesToPdfState state,
    ImagesToPdfViewModel notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ReorderableImageGrid(
            images: state.selectedImages,
            onReorder: notifier.reorderImages,
            onRemove: notifier.removeImage,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  initialValue: state.pdfFileName,
                  decoration: const InputDecoration(
                    labelText: 'PDF File Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: notifier.setPdfFileName,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: state.isProcessing
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.picture_as_pdf),
                  label: Text(
                    state.isProcessing ? 'Processing...' : 'Convert & Save',
                  ),
                  onPressed: state.isProcessing
                      ? null
                      : () async {
                          await notifier.convertAndSavePdf();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('PDF saved successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
