import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/core/services/native_pdf_compression_service.dart';
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
            // This error is for when the provider itself fails to build.
            return Center(child: Text('Failed to load PDF: $err'));
          },
          data: (state) =>
              _buildContent(context, state, notifier, viewModel.isLoading, ref),
        ),
      ),
    );
  }

  /// Builds the main content of the screen based on the current state.
  Widget _buildContent(
    BuildContext context,
    PdfCompressionState state,
    PdfCompressionViewModel notifier,
    bool isProcessing,
    WidgetRef ref,
  ) {
    if (state.pickedPdf == null) {
      return const Center(child: Text('No PDF was selected. Please go back.'));
    }

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
              final result = await notifier.compressAndSavePdf(
                fileName: saveResult.fileName,
                folderPath: saveResult.folderPath,
              );

              if (context.mounted) {
                // Use a switch statement to show the
                // correct toast for each outcome.
                switch (result.status) {
                  case NativeCompressionStatus.success:
                    showToast(context, 'Successfully compressed and saved!');
                  case NativeCompressionStatus.successWithFallback:
                    showToast(
                      context,
                      'Success! Text may not be selectable '
                      'in the compressed file.',
                      type: ToastType.info,
                    );
                  case NativeCompressionStatus.errorSizeLimit:
                    showToast(
                      context,
                      result.message ??
                          'Could not compress to the target size.',
                      type: ToastType.warning,
                    );
                  case NativeCompressionStatus.errorOutOfMemory:
                    showToast(
                      context,
                      'Compression failed: The PDF is '
                      'too large for this device.',
                      type: ToastType.error,
                    );
                  case NativeCompressionStatus.errorBadPassword:
                    showToast(
                      context,
                      'Compression failed: The PDF is'
                      ' password-protected or corrupted.',
                      type: ToastType.error,
                    );
                  case NativeCompressionStatus.errorTextTooLarge:
                    showToast(
                      context,
                      result.message ??
                          'The text content alone is larger '
                              'than the target size.',
                      type: ToastType.warning,
                    );
                  case NativeCompressionStatus.errorUnknown:
                    showToast(
                      context,
                      result.message ?? 'An unknown error occurred.',
                      type: ToastType.error,
                    );
                }

                // Only pop the screen on success.
                if (result.status == NativeCompressionStatus.success ||
                    result.status ==
                        NativeCompressionStatus.successWithFallback) {
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
