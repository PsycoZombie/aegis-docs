import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/features/document_prep/providers/pdf_to_images_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/pdf_to_images/selectable_image_grid.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/multi_save_options_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

/// A screen for converting a selected PDF document into a series of images.
class PdfToImagesScreen extends ConsumerWidget {
  /// Creates an instance of [PdfToImagesScreen].
  const PdfToImagesScreen({super.key, this.initialFile});

  /// The initial PDF file to be processed, passed from the previous screen.
  final PickedFileModel? initialFile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the ViewModel provider, passing in the initial file.
    final viewModel = ref.watch(pdfToImagesViewModelProvider(initialFile));
    final notifier = ref.read(
      pdfToImagesViewModelProvider(initialFile).notifier,
    );

    return AppScaffold(
      title: 'PDF to Images',
      body: Padding(
        padding: const EdgeInsets.all(16),
        // Use .when to handle loading, error, and data states of the provider.
        child: viewModel.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('An error occurred: $err')),
          data: (state) {
            if (state.originalPdf == null) {
              return const Center(
                child: Text('No PDF was selected. Please go back.'),
              );
            }
            // Pass the provider's state and notifier to the content widget.
            return _buildContent(context, state, notifier, viewModel, ref);
          },
        ),
      ),
    );
  }

  /// Builds the main content of the screen based on the current state.
  Widget _buildContent(
    BuildContext context,
    PdfToImagesState state,
    PdfToImagesViewModel notifier,
    AsyncValue<PdfToImagesState> viewModel, // Pass the full AsyncValue
    WidgetRef ref,
  ) {
    // Determine if any operation is in progress by
    // checking the provider's state.
    final isProcessing = viewModel.isLoading;

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
                    icon: isProcessing
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.transform),
                    label: Text(
                      isProcessing ? 'Converting...' : 'Convert to Images',
                    ),
                    onPressed: isProcessing ? null : notifier.convertToImages,
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
            icon: isProcessing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_alt_outlined),
            label: Text(
              isProcessing
                  ? 'Saving...'
                  : 'Save Selected (${state.selectedImageIndices.length})',
            ),
            onPressed: isProcessing || state.selectedImageIndices.isEmpty
                ? null
                : () async {
                    final defaultName = p.basenameWithoutExtension(
                      state.originalPdf!.name,
                    );

                    final saveResult = await showMultiSaveOptionsDialog(
                      context,
                      defaultBaseName: defaultName,
                      fileCount: state.selectedImageIndices.length,
                    );

                    if (saveResult != null && context.mounted) {
                      await notifier.saveSelectedImages(
                        baseName: saveResult.baseName,
                        folderPath: saveResult.folderPath,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Saved ${state.selectedImageIndices.length}'
                              ' images!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        ref.invalidate(walletViewModelProvider);
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
