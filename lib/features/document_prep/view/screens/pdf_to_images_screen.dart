import 'package:aegis_docs/features/document_prep/providers/pdf_to_images_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/pdf_to_images/selectable_image_grid.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/multi_save_options_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

class PdfToImagesScreen extends ConsumerWidget {
  const PdfToImagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(pdfToImagesViewModelProvider);
    final notifier = ref.read(pdfToImagesViewModelProvider.notifier);

    return AppScaffold(
      title: 'PDF to Images',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: viewModel.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('An error occurred: $err')),
          data: (state) {
            if (state.originalPdf == null) {
              return Center(
                child: FilledButton.icon(
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Select a PDF'),
                  onPressed: () => notifier.pickPdf(),
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
    PdfToImagesState state,
    PdfToImagesViewModel notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text(
              state.originalPdf!.name,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: const Text('Selected PDF'),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: state.generatedImages.isEmpty
              ? Center(
                  child: FilledButton.icon(
                    icon: state.isProcessing
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.transform),
                    label: Text(
                      state.isProcessing
                          ? 'Converting...'
                          : 'Convert to Images',
                    ),
                    onPressed: state.isProcessing
                        ? null
                        : notifier.convertToImages,
                  ),
                )
              : SelectableImageGrid(
                  images: state.generatedImages,
                  selectedIndices: state.selectedImageIndices,
                  onImageTap: notifier.toggleImageSelection,
                ),
        ),
        if (state.generatedImages.isNotEmpty) ...[
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
                : const Icon(Icons.save_alt_outlined),
            label: Text(
              state.isProcessing
                  ? 'Saving...'
                  : 'Save Selected (${state.selectedImageIndices.length})',
            ),
            onPressed: state.isProcessing || state.selectedImageIndices.isEmpty
                ? null
                : () async {
                    final defaultName = p.basenameWithoutExtension(
                      state.originalPdf!.name,
                    );

                    final baseName = await showMultiSaveOptionsDialog(
                      context,
                      defaultBaseName: defaultName,
                      fileCount: state.selectedImageIndices.length,
                    );

                    if (baseName != null) {
                      await notifier.saveSelectedImages(baseName: baseName);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Saved ${state.selectedImageIndices.length} images!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        context.pop();
                      }
                    }
                  },
          ),
        ],
      ],
    );
  }
}
