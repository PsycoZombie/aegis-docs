import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/features/document_prep/providers/pdf_compression_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/pdf_compression/pdf_option_cards_widget.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/pdf_compression/pdf_preview_section.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/save_options_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

class PdfCompressionScreen extends ConsumerWidget {
  final PickedFile? initialFile;
  const PdfCompressionScreen({super.key, this.initialFile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(pdfCompressionViewModelProvider(initialFile));
    final notifier = ref.read(
      pdfCompressionViewModelProvider(initialFile).notifier,
    );

    ref.listen(pdfCompressionViewModelProvider(initialFile), (previous, next) {
      if (next is AsyncData) {
        final state = next.value;
        if (state!.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });

    return AppScaffold(
      title: 'Compress PDF',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: viewModel.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('An error occurred: $err')),
          data: (state) {
            if (state.pickedPdf == null) {
              return const Center(
                child: Text('No PDF was selected. Please go back.'),
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
    PdfCompressionState state,
    PdfCompressionViewModel notifier,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(child: PdfPreviewSection(state: state)),
        ),
        const SizedBox(height: 16),
        PdfOptionsCard(
          state: state,
          notifier: notifier,
          onSave: () async {
            final originalName = p.basenameWithoutExtension(
              state.pickedPdf!.name,
            );
            final defaultName = 'compressed_$originalName';

            final newName = await showSaveOptionsDialog(
              context,
              defaultFileName: defaultName,
              fileExtension: '.pdf',
            );

            if (newName != null) {
              final success = await notifier.compressAndSavePdf(
                fileName: newName,
              );
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PDF compressed and saved!'),
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
