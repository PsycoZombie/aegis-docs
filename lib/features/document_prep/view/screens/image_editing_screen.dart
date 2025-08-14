import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/features/document_prep/providers/image_editing_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_editing/editing_toolbar.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/save_options_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

class ImageEditingScreen extends ConsumerWidget {
  final PickedFile? initialFile;
  const ImageEditingScreen({super.key, this.initialFile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(imageEditingViewModelProvider(initialFile));
    final notifier = ref.read(
      imageEditingViewModelProvider(initialFile).notifier,
    );

    return AppScaffold(
      title: 'Edit Image',
      actions: [
        if (viewModel.value?.currentImage != null)
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save Image',
            onPressed: () async {
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

              if (saveResult != null) {
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
      body: viewModel.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('An error occurred: $err')),
        data: (state) {
          if (state.currentImage == null) {
            return const Center(
              child: Text('No image was selected. Please go back.'),
            );
          }
          return _buildContent(context, state, notifier);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ImageEditingState state,
    ImageEditingViewModel notifier,
  ) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: InteractiveViewer(child: Image.memory(state.currentImage!)),
          ),
        ),
        EditingToolbar(
          onCrop: () => notifier.cropImage(context: context),
          onUndo: state.editHistory.isNotEmpty ? () => notifier.undo() : null,
          onGrayscale: () => notifier.applyGrayscaleFilter(),
        ),
      ],
    );
  }
}
