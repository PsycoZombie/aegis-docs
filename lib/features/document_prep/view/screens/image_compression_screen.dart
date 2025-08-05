import 'package:aegis_docs/features/document_prep/providers/image_compression_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_compression/compression_options_card.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_compression/image_preview_section.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageCompressionScreen extends ConsumerWidget {
  const ImageCompressionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(imageCompressionViewModelProvider);
    final notifier = ref.read(imageCompressionViewModelProvider.notifier);

    ref.listen(imageCompressionViewModelProvider, (previous, next) {
      if (next is AsyncData &&
          next.value!.compressionStatus == CompressionStatus.failure) {
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: viewModel.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('An error occurred: $err')),
          data: (state) {
            if (state.originalImage == null) {
              return Center(
                child: FilledButton.icon(
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Pick an Image'),
                  onPressed: () async {
                    final wasConverted = await notifier.pickImage();
                    if (wasConverted && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Unsupported format was converted to JPG.',
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
    CompressionState state,
    ImageCompressionViewModel notifier,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: CompressionImagePreviewSection(state: state),
          ),
        ),
        const SizedBox(height: 16),
        CompressionOptionsCard(state: state, notifier: notifier),
      ],
    );
  }
}
