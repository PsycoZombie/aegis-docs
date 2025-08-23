import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/features/document_prep/providers/image_format_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_format/format_options_card.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_format/image_preview_section.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/save_options_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

/// A screen for changing the file format of an image (e.g., from PNG to JPG).
class ImageFormatScreen extends ConsumerWidget {
  /// Creates an instance of [ImageFormatScreen].
  const ImageFormatScreen({super.key, this.initialFile});

  /// The initial image file to be processed.
  final PickedFileModel? initialFile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(imageFormatViewModelProvider(initialFile));
    final notifier = ref.read(
      imageFormatViewModelProvider(initialFile).notifier,
    );

    return AppScaffold(
      title: 'Change Image Format',
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
    ImageFormatState state,
    ImageFormatViewModel notifier,
    AsyncValue<ImageFormatState> viewModel,
    WidgetRef ref,
  ) {
    // Determine if any operation is in progress by
    // checking the provider's state.
    final isProcessing = viewModel.isLoading;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: FormatImagePreviewSection(state: state),
          ),
        ),
        const SizedBox(height: 16),
        FormatOptionsCard(
          state: state,
          notifier: notifier,
          isProcessing: isProcessing,
          onSave: () async {
            final originalName = p.basenameWithoutExtension(
              state.originalImage!.name,
            );
            final extension = '.${state.targetFormat}';
            final defaultName = '${originalName}_formatted';

            final saveResult = await showSaveOptionsDialog(
              context,
              defaultFileName: defaultName,
              fileExtension: extension,
            );

            if (saveResult != null && context.mounted) {
              await notifier.saveImage(
                fileName: saveResult.fileName,
                folderPath: saveResult.folderPath,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Image saved successfully!'),
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
    );
  }
}
