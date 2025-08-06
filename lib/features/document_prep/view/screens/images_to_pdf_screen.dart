import 'package:aegis_docs/features/document_prep/providers/images_to_pdf_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/images_to_pdf/images_to_pdf_options_card.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/images_to_pdf/reorderable_image_grid.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/save_options_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

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
                  onPressed: () async {
                    final anyConverted = await notifier.pickImages();
                    if (anyConverted && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'One or more unsupported formats were converted to JPG.',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
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
        ImagesToPdfOptionsCard(
          state: state,
          notifier: notifier,
          onSave: () async {
            final originalName = p.basenameWithoutExtension(
              state.selectedImages.first.name,
            );
            final defaultName = '${originalName}_document';

            final newName = await showSaveOptionsDialog(
              context,
              defaultFileName: defaultName,
              fileExtension: '.pdf',
            );

            if (newName != null) {
              await notifier.savePdf(fileName: newName);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PDF saved successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.pop();
              }
            }
          },
        ),
      ],
    );
  }
}
