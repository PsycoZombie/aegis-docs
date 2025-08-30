// lib/features/document_prep/view/screens/pdf_compression_screen.dart

import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/core/services/native_pdf_compression_service.dart';
import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/features/document_prep/providers/pdf_compression_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/pdf_compression/pdf_option_cards_widget.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/pdf_compression/pdf_preview_section.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/password_dialog.dart';
import 'package:aegis_docs/shared_widgets/save_options_dialog.dart';
import 'package:aegis_docs/shared_widgets/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart' show PdfPasswordException;

/// A screen for native PDF compression
class PdfCompressionScreen extends ConsumerWidget {
  /// Creates an instance of [PdfCompressionScreen].
  const PdfCompressionScreen({super.key, this.initialFile});

  /// An initial file to be processed, passed from the previous screen.
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
          error: (err, stack) =>
              Center(child: Text('Failed to load PDF: $err')),
          data: (state) =>
              _buildContent(context, state, notifier, viewModel.isLoading, ref),
        ),
      ),
    );
  }

  // The UI logic moves inside this helper ---
  Future<void> _handleCompression(
    BuildContext context,
    WidgetRef ref,
    PdfCompressionViewModel notifier, {
    String? password, // Now accepts an optional password
  }) async {
    final state = ref.read(pdfCompressionViewModelProvider(initialFile)).value;
    if (state?.pickedPdf == null || !context.mounted) return;

    final originalName = p.basenameWithoutExtension(state!.pickedPdf!.name);
    final defaultName = 'compressed_$originalName';

    final saveResult = await showSaveOptionsDialog(
      context,
      defaultFileName: defaultName,
      fileExtension: '.pdf',
    );
    if (saveResult == null || !context.mounted) return;

    try {
      final result = await notifier.compressAndSavePdf(
        fileName: saveResult.fileName,
        folderPath: saveResult.folderPath,
        password: password,
      );

      if (!context.mounted) return;
      _showResultToast(context, result);
      if (result.status == NativeCompressionStatus.success ||
          result.status == NativeCompressionStatus.successWithFallback) {
        ref.invalidate(walletViewModelProvider);
        context.pop();
      }
    } on PdfPasswordException {
      // CATCH THE ERROR: If a password is required, show the dialog.
      if (context.mounted) {
        final newPassword = await showPasswordDialog(context);
        if (newPassword != null && newPassword.isNotEmpty && context.mounted) {
          // RETRY: Call this whole function again, but with the password.
          await _handleCompression(
            context,
            ref,
            notifier,
            password: newPassword,
          );
        }
      }
    }
  }

  // Extracted toast logic for clarity
  void _showResultToast(BuildContext context, PdfCompressionResult result) {
    switch (result.status) {
      case NativeCompressionStatus.success:
        showToast(context, 'Successfully compressed and saved!');
      case NativeCompressionStatus.successWithFallback:
        showToast(
          context,
          'Success! Text may not be selectable.',
          type: ToastType.info,
        );
      case NativeCompressionStatus.errorSizeLimit:
        showToast(
          context,
          result.message ?? 'Could not compress to target size.',
          type: ToastType.warning,
        );
      case NativeCompressionStatus.errorOutOfMemory:
        showToast(
          context,
          'Compression failed: PDF is too large for this device.',
          type: ToastType.error,
        );
      case NativeCompressionStatus.errorBadPassword:
        showToast(
          context,
          result.message ?? 'Incorrect password or corrupted file.',
          type: ToastType.error,
        );
      case NativeCompressionStatus.errorTextTooLarge:
        showToast(
          context,
          result.message ?? 'Text content is larger than target size.',
          type: ToastType.warning,
        );
      case NativeCompressionStatus.errorUnknown:
        showToast(
          context,
          result.message ?? 'An unknown error occurred.',
          type: ToastType.error,
        );
    }
  }

  Widget _buildContent(
    BuildContext context,
    PdfCompressionState state,
    PdfCompressionViewModel notifier,
    bool isProcessing,
    WidgetRef ref,
  ) {
    if (state.pickedPdf == null) {
      return const Center(child: Text('No PDF selected.'));
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
          onSave: () => _handleCompression(context, ref, notifier),
        ),
      ],
    );
  }
}
