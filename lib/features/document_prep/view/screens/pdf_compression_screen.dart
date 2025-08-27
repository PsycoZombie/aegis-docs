import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/features/document_prep/providers/pdf_compression_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/pdf_compression/pdf_option_cards_widget.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/pdf_compression/pdf_preview_section.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/save_options_dialog.dart';
import 'package:aegis_docs/shared_widgets/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

/// A screen for compressing a PDF document using the native implementation.
class PdfCompressionScreen extends ConsumerWidget {
  /// Creates an instance of [PdfCompressionScreen].
  const PdfCompressionScreen({super.key, this.initialFile});

  /// The initial PDF file to be processed, passed from the previous screen.
  final PickedFileModel? initialFile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(pdfCompressionViewModelProvider(initialFile));
    final notifier = ref.read(
      pdfCompressionViewModelProvider(initialFile).notifier,
    );

    return AppScaffold(
      title: AppConstants.titleCompressPdf,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: viewModel.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) {
            // On error, show a Toast and display the last valid data.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showToast(
                context,
                'An error occurred: $err',
                type: ToastType.error,
              );
            });
            if (viewModel.value == null) {
              return Center(child: Text('Failed to load PDF: $err'));
            }
            return _buildContent(
              context,
              viewModel.value!,
              notifier,
              viewModel,
              ref,
            );
          },
          data: (state) =>
              _buildContent(context, state, notifier, viewModel, ref),
        ),
      ),
    );
  }

  /// Builds the main content of the screen based on the current state.
  Widget _buildContent(
    BuildContext context,
    PdfCompressionState state,
    PdfCompressionViewModel notifier,
    AsyncValue<PdfCompressionState> viewModel,
    WidgetRef ref,
  ) {
    if (state.pickedPdf == null) {
      return const Center(child: Text('No PDF was selected. Please go back.'));
    }

    final isProcessing = viewModel.isLoading;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(child: PdfPreviewSection(state: state)),
        ),
        const SizedBox(height: 16),
        PdfOptionsCard(
          state: state,
          notifier: notifier,
          isProcessing: isProcessing,
          onSave: () async {
            final originalName = p.basenameWithoutExtension(
              state.pickedPdf!.name,
            );
            final defaultName = 'compressed_$originalName';

            final saveResult = await showSaveOptionsDialog(
              context,
              defaultFileName: defaultName,
              fileExtension: '.pdf',
            );

            if (saveResult != null && context.mounted) {
              final success = await notifier.compressAndSavePdf(
                fileName: saveResult.fileName,
                folderPath: saveResult.folderPath,
              );
              if (context.mounted) {
                if (success) {
                  showToast(context, 'Successfully compressed and saved!');
                } else {
                  showToast(
                    context,
                    'Compression failed. Please try again.',
                    type: ToastType.error,
                  );
                }
                if (success) {
                  ref.invalidate(walletViewModelProvider);
                  context.pop();
                }
              }
            }
          },
        ),
      ],
    );
  }
}
