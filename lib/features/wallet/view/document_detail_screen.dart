import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentDetailScreen extends ConsumerWidget {
  final String fileName;

  const DocumentDetailScreen({super.key, required this.fileName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentAsyncValue = ref.watch(
      documentDetailProvider(fileName: fileName),
    );
    final isPdf = fileName.toLowerCase().endsWith('.pdf');

    return AppScaffold(
      title: fileName,
      body: Center(
        child: documentAsyncValue.when(
          // 1. Reverted to CircularProgressIndicator
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error loading document: $error'),
          data: (decryptedData) {
            if (decryptedData == null) {
              // 2. Reverted to standard Text widget
              return const Text('Could not load or decrypt the document.');
            }

            final Widget documentView = isPdf
                ? SfPdfViewer.memory(decryptedData)
                : InteractiveViewer(
                    child: Image.memory(decryptedData, fit: BoxFit.contain),
                  );

            // 3. Reverted to a Card for a clean container with elevation
            return Card(
              elevation: 4,
              clipBehavior:
                  Clip.antiAlias, // Ensures content respects the shape
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: documentView,
            );
          },
        ),
      ),
    );
  }
}
