import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/features/document_prep/providers/image_compression_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_compression/compression_options_card.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_compression/image_preview_section.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/save_options_dialog.dart';
import 'package:aegis_docs/shared_widgets/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

/// A screen for compressing an image to a target file size.
class ImageCompressionScreen extends ConsumerWidget {
  /// Creates an instance of [ImageCompressionScreen].
  const ImageCompressionScreen({super.key, this.initialFile});

  /// The initial image file to be processed.
  final PickedFileModel? initialFile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(imageCompressionViewModelProvider(initialFile));
    final notifier = ref.read(
      imageCompressionViewModelProvider(initialFile).notifier,
    );

    // Listen for specific state changes to show non-blocking feedback.
    ref.listen(imageCompressionViewModelProvider(initialFile), (
      previous,
      next,
    ) {
      if (next is AsyncData &&
          next.value?.compressionStatus == CompressionStatus.failure) {
        showToast(
          context,
          'Could not compress further.'
          ' Image may already be optimized.',
          type: ToastType.warning,
        );
      }
    });

    return AppScaffold(
      title: AppConstants.titleCompressImage,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: viewModel.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('An error occurred: $err')),
          data: (state) {
            if (state.originalImage == null) {
              return const Center(
                child: Text('No image was selected. Please go back.'),
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
    CompressionState state,
    ImageCompressionViewModel notifier,
    AsyncValue<CompressionState> viewModel,
    WidgetRef ref,
  ) {
    // Determine if any operation is in progress by
    // checking the provider's state.
    final isProcessing = viewModel.isLoading;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: CompressionImagePreviewSection(state: state),
          ),
        ),
        const SizedBox(height: 16),
        CompressionOptionsCard(
          state: state,
          notifier: notifier,
          isProcessing: isProcessing,
          onSave: () async {
            final originalName = p.basenameWithoutExtension(
              state.originalImage!.name,
            );
            final extension = p.extension(state.originalImage!.name);
            final defaultName = 'compressed_$originalName';

            final saveResult = await showSaveOptionsDialog(
              context,
              defaultFileName: defaultName,
              fileExtension: extension.isNotEmpty ? extension : '.jpg',
            );

            if (saveResult != null && context.mounted) {
              await notifier.saveCompressedImage(
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
    );
  }
}
