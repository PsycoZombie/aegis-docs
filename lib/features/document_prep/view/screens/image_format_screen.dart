import 'package:aegis_docs/features/document_prep/providers/image_format_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_format/format_options_card.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_format/image_preview_section.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageFormatScreen extends ConsumerWidget {
  const ImageFormatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(imageFormatViewModelProvider);
    final notifier = ref.read(imageFormatViewModelProvider.notifier);

    return AppScaffold(
      title: 'Change Image Format',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: viewModel.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('An error occurred: $err')),
          data: (state) {
            if (state.originalImage == null) {
              return Center(
                child: FilledButton.icon(
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Select an Image'),
                  onPressed: () => notifier.pickImage(),
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
    ImageFormatState state,
    ImageFormatViewModel notifier,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: FormatImagePreviewSection(state: state),
          ),
        ),
        const SizedBox(height: 16),
        FormatOptionsCard(state: state, notifier: notifier),
      ],
    );
  }
}
