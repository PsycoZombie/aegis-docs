import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/features/document_prep/providers/images_to_pdf_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/images_to_pdf/images_to_pdf_options_card.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/images_to_pdf/reorderable_image_grid.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/save_options_dialog.dart';
import 'package:aegis_docs/shared_widgets/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

/// A screen for arranging and converting a list of
/// images into a single PDF document.
class ImagesToPdfScreen extends ConsumerWidget {
  /// Creates an instance of [ImagesToPdfScreen].
  const ImagesToPdfScreen({required this.initialFiles, super.key});

  /// The list of initial image files to be processed.
  final List<PickedFileModel> initialFiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(imagesToPdfViewModelProvider(initialFiles));
    final notifier = ref.read(
      imagesToPdfViewModelProvider(initialFiles).notifier,
    );

    return AppScaffold(
      title: AppConstants.titleImagesToPdf,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: viewModel.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('An error occurred: $err')),
          data: (state) {
            if (state.selectedImages.isEmpty) {
              return const Center(
                child: Text('No images were selected. Please go back.'),
              );
            }
            return _buildContent(context, state, notifier, viewModel, ref);
          },
        ),
      ),
    );
  }

  /// Builds the main content of the screen based on the current state.
  Widget _buildContent(
    BuildContext context,
    ImagesToPdfState state,
    ImagesToPdfViewModel notifier,
    AsyncValue<ImagesToPdfState> viewModel,
    WidgetRef ref,
  ) {
    // Determine if any operation is in progress by
    // checking the provider's state.
    final isProcessing = viewModel.isLoading;

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
          isProcessing: isProcessing,
          onSave: () async {
            final originalName = p.basenameWithoutExtension(
              state.selectedImages.first.name,
            );
            final defaultName = '${originalName}_document';

            final saveResult = await showSaveOptionsDialog(
              context,
              defaultFileName: defaultName,
              fileExtension: '.pdf',
            );

            if (saveResult != null && context.mounted) {
              await notifier.savePdf(
                fileName: saveResult.fileName,
                folderPath: saveResult.folderPath,
              );
              if (context.mounted) {
                showToast(context, 'PDF saved successfully!');
                ref.invalidate(walletViewModelProvider);
                context.pop();
              }
            }
          },
        ),
      ],
    );
  }
}
