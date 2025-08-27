import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/features/document_prep/providers/image_editing_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_editing/editing_toolbar.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/save_options_dialog.dart';
import 'package:aegis_docs/shared_widgets/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

/// A screen for performing basic edits on an image,
/// like cropping and applying filters.
class ImageEditingScreen extends ConsumerWidget {
  /// Creates an instance of [ImageEditingScreen].
  const ImageEditingScreen({super.key, this.initialFile});

  /// The initial image file to be edited.
  final PickedFileModel? initialFile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(imageEditingViewModelProvider(initialFile));
    final notifier = ref.read(
      imageEditingViewModelProvider(initialFile).notifier,
    );

    // Determine if any operation is in progress by
    // checking the provider's state.
    final isProcessing = viewModel.isLoading;

    return AppScaffold(
      title: AppConstants.titleCropEditImage,
      actions: [
        // Show the save button only when there is an image to save.
        if (viewModel.value?.currentImage != null)
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save Image',
            // Disable the button while an operation is in progress.
            onPressed: isProcessing
                ? null
                : () async {
                    final state = viewModel.value;
                    if (state?.originalImage == null) return;

                    final originalName = p.basenameWithoutExtension(
                      state!.originalImage!.name,
                    );
                    final extension = p.extension(state.originalImage!.name);
                    final defaultName = 'edited_$originalName';

                    final saveResult = await showSaveOptionsDialog(
                      context,
                      defaultFileName: defaultName,
                      fileExtension: extension.isNotEmpty ? extension : '.jpg',
                    );

                    if (saveResult != null && context.mounted) {
                      await notifier.saveImage(
                        fileName: saveResult.fileName,
                        folderPath: saveResult.folderPath,
                      );
                      if (context.mounted) {
                        showToast(context, 'Image saved successfully!');
                        ref.invalidate(walletViewModelProvider);
                        context.pop();
                      }
                    }
                  },
          ),
      ],
      body: viewModel.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('An error occurred: $err')),
        data: (state) {
          if (state.currentImage == null) {
            return const Center(
              child: Text('No image was selected. Please go back.'),
            );
          }
          return _buildContent(context, state, notifier, isProcessing);
        },
      ),
    );
  }

  /// Builds the main content of the screen,
  /// including the image viewer and toolbar.
  Widget _buildContent(
    BuildContext context,
    ImageEditingState state,
    ImageEditingViewModel notifier,
    bool isProcessing,
  ) {
    return Column(
      children: [
        Expanded(
          child: Center(
            // InteractiveViewer allows for pan and zoom functionality.
            child: InteractiveViewer(child: Image.memory(state.currentImage!)),
          ),
        ),
        EditingToolbar(
          isProcessing: isProcessing,
          onCrop: () => notifier.cropImage(theme: Theme.of(context)),
          onUndo: state.editHistory.isNotEmpty ? () => notifier.undo() : null,
          onGrayscale: () => notifier.applyGrayscaleFilter(),
        ),
      ],
    );
  }
}
