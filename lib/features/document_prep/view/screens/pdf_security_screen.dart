import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/features/document_prep/providers/pdf_security_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/pdf_security/security_options_card.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/save_options_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

/// A screen for managing the password protection of a PDF document.
class PdfSecurityScreen extends ConsumerWidget {
  /// Creates an instance of [PdfSecurityScreen].
  const PdfSecurityScreen({super.key, this.initialFile});

  /// The initial PDF file to be processed, passed from the previous screen.
  final PickedFileModel? initialFile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(pdfSecurityViewModelProvider(initialFile));
    final notifier = ref.read(
      pdfSecurityViewModelProvider(initialFile).notifier,
    );

    return AppScaffold(
      title: AppConstants.titlePdfSecurity,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: viewModel.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) {
            // On error, show a SnackBar and display the
            // last valid data if available.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('An error occurred: $err'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            });
            // Show the previous data to avoid a blank screen on error.
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
    PdfSecurityState state,
    PdfSecurityViewModel notifier,
    AsyncValue<PdfSecurityState> viewModel,
    WidgetRef ref,
  ) {
    if (state.pickedPdf == null) {
      return const Center(child: Text('No PDF was selected. Please go back.'));
    }

    final isProcessing = viewModel.isLoading;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.picture_as_pdf, size: 100, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  state.pickedPdf!.name,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (state.isEncrypted != null)
                  Chip(
                    avatar: Icon(
                      state.isEncrypted! ? Icons.lock : Icons.lock_open,
                      color: state.isEncrypted! ? Colors.orange : Colors.green,
                    ),
                    label: Text(
                      state.isEncrypted!
                          ? 'Password Protected'
                          : 'Not Protected',
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SecurityOptionsCard(
          state: state,
          notifier: notifier,
          isProcessing: isProcessing,
          onSave: () async {
            final originalName = p.basenameWithoutExtension(
              state.pickedPdf!.name,
            );
            final defaultName = 'secured_$originalName';

            final saveResult = await showSaveOptionsDialog(
              context,
              defaultFileName: defaultName,
              fileExtension: '.pdf',
            );

            if (saveResult != null && context.mounted) {
              await notifier.savePdf(
                fileName: saveResult.fileName,
                folderPath: saveResult.folderPath,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PDF saved successfully!'),
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
