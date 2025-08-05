import 'package:aegis_docs/features/document_prep/providers/pdf_compression_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/pdf_compression/pdf_option_cards_widget.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/pdf_compression/pdf_preview_section.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PdfCompressionScreen extends ConsumerWidget {
  const PdfCompressionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(pdfCompressionViewModelProvider);
    final notifier = ref.read(pdfCompressionViewModelProvider.notifier);

    return AppScaffold(
      title: 'Compress PDF',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: viewModel.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('An error occurred: $err')),
          data: (state) {
            if (state.pickedPdf == null) {
              return Center(
                child: FilledButton.icon(
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Select a PDF to Compress'),
                  onPressed: () => notifier.pickPdf(),
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
    PdfCompressionState state,
    PdfCompressionViewModel notifier,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(child: PdfPreviewSection(state: state)),
        ),
        const SizedBox(height: 16),
        PdfOptionsCard(state: state, notifier: notifier),
      ],
    );
  }
}
