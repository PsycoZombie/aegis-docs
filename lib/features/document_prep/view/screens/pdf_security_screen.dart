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

class PdfSecurityScreen extends ConsumerWidget {
  const PdfSecurityScreen({super.key, this.initialFile});
  final PickedFile? initialFile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(pdfSecurityViewModelProvider(initialFile));
    final notifier = ref.read(
      pdfSecurityViewModelProvider(initialFile).notifier,
    );

    ref.listen(pdfSecurityViewModelProvider(initialFile), (previous, next) {
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
      title: 'PDF Security',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: viewModel.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              _buildData(context, viewModel.asData!.value, notifier, ref),
          data: (state) => _buildData(context, state, notifier, ref),
        ),
      ),
    );
  }

  Widget _buildData(
    BuildContext context,
    PdfSecurityState state,
    PdfSecurityViewModel notifier,
    WidgetRef ref,
  ) {
    if (state.pickedPdf == null) {
      return const Center(child: Text('No PDF was selected. Please go back.'));
    }
    return _buildContent(context, state, notifier, ref);
  }

  Widget _buildContent(
    BuildContext context,
    PdfSecurityState state,
    PdfSecurityViewModel notifier,
    WidgetRef ref,
  ) {
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

            if (saveResult != null) {
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
