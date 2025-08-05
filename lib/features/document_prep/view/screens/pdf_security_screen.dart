import 'package:aegis_docs/features/document_prep/providers/pdf_security_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/pdf_security/security_options_card.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PdfSecurityScreen extends ConsumerWidget {
  const PdfSecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(pdfSecurityViewModelProvider);
    final notifier = ref.read(pdfSecurityViewModelProvider.notifier);

    ref.listen(pdfSecurityViewModelProvider, (previous, next) {
      if (next is AsyncData) {
        final state = next.value;
        if (state!.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state.errorMessage != null) {
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
        padding: const EdgeInsets.all(16.0),
        child: viewModel.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              _buildData(context, viewModel.asData!.value, notifier),
          data: (state) => _buildData(context, state, notifier),
        ),
      ),
    );
  }

  Widget _buildData(
    BuildContext context,
    PdfSecurityState state,
    PdfSecurityViewModel notifier,
  ) {
    if (state.pickedPdf == null) {
      return Center(
        child: FilledButton.icon(
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('Select a PDF'),
          onPressed: () => notifier.pickPdf(),
        ),
      );
    }
    return _buildContent(context, state, notifier);
  }

  Widget _buildContent(
    BuildContext context,
    PdfSecurityState state,
    PdfSecurityViewModel notifier,
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
        SecurityOptionsCard(state: state, notifier: notifier),
      ],
    );
  }
}
