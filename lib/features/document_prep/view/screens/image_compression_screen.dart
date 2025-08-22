import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/features/document_prep/providers/image_compression_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_compression/compression_options_card.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_compression/image_preview_section.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/save_options_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

class ImageCompressionScreen extends ConsumerWidget {
  const ImageCompressionScreen({super.key, this.initialFile});
  final PickedFile? initialFile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(imageCompressionViewModelProvider(initialFile));
    final notifier = ref.read(
      imageCompressionViewModelProvider(initialFile).notifier,
    );

    ref.listen(imageCompressionViewModelProvider(initialFile), (
      previous,
      next,
    ) {
      if (next is AsyncData &&
          next.value?.compressionStatus == CompressionStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not compress further. Image may already be optimized.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });

    return AppScaffold(
      title: 'Compress Image',
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
            return _buildContent(context, state, notifier, ref);
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CompressionState state,
    ImageCompressionViewModel notifier,
    WidgetRef ref,
  ) {
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

            if (saveResult != null) {
              await notifier.saveCompressedImage(
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
