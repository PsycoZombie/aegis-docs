import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/features/document_prep/providers/image_format_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_format/format_options_card.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_format/image_preview_section.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/save_options_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

class ImageFormatScreen extends ConsumerWidget {
  final PickedFile? initialFile;
  const ImageFormatScreen({super.key, this.initialFile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(imageFormatViewModelProvider(initialFile));
    final notifier = ref.read(
      imageFormatViewModelProvider(initialFile).notifier,
    );

    return AppScaffold(
      title: 'Change Image Format',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: viewModel.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('An error occurred: $err')),
          data: (state) {
            if (state.originalImage == null) {
              return const Center(
                child: Text('No image was selected. Please go back.'),
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
        FormatOptionsCard(
          state: state,
          notifier: notifier,
          onSave: () async {
            final originalName = p.basenameWithoutExtension(
              state.originalImage!.name,
            );
            final extension = '.${state.targetFormat}';
            final defaultName = '${originalName}_formatted';

            final newName = await showSaveOptionsDialog(
              context,
              defaultFileName: defaultName,
              fileExtension: extension,
            );

            if (newName != null) {
              await notifier.saveImage(fileName: newName);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Image saved successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.pop();
              }
            }
          },
        ),
      ],
    );
  }
}
