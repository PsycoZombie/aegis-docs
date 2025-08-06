import 'package:aegis_docs/data/models/picked_file_model.dart';
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
  final List<PickedFile> initialFiles;
  const ImagesToPdfScreen({super.key, required this.initialFiles});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(imagesToPdfViewModelProvider(initialFiles));
    final notifier = ref.read(
      imagesToPdfViewModelProvider(initialFiles).notifier,
    );

    return AppScaffold(
      title: 'Images to PDF',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: viewModel.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('An error occurred: $err')),
          data: (state) {
            if (state.selectedImages.isEmpty) {
              return const Center(
                child: Text('No images were selected. Please go back.'),
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
