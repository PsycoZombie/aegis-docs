import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// A screen that displays the content of a single decrypted document.
///
/// It determines whether to show a PDF viewer or an image viewer based on the
/// file extension.
class DocumentDetailScreen extends ConsumerWidget {
  /// Creates an instance of [DocumentDetailScreen].
  const DocumentDetailScreen({
    required this.fileName,
    this.folderPath,
    super.key,
  });

  /// The name of the document to display.
  final String fileName;

  /// The path of the folder containing the document.
  final String? folderPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider that fetches and
    // decrypts the specific document's content.
    final documentAsyncValue = ref.watch(
      documentDetailProvider(fileName: fileName, folderPath: folderPath),
    );
    final isPdf = fileName.toLowerCase().endsWith('.pdf');

    return AppScaffold(
      title: fileName,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: documentAsyncValue.when(
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error loading document: $error'),
            data: (decryptedData) {
              if (decryptedData == null) {
                return const Text('Could not load or decrypt the document.');
              }

              // Choose the appropriate viewer based on the file type.
              final Widget documentView = isPdf
                  ? SfPdfViewer.memory(decryptedData)
                  : InteractiveViewer(
                      child: Image.memory(decryptedData, fit: BoxFit.contain),
                    );

              return Card(
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: documentView,
              );
            },
          ),
        ),
      ),
    );
  }
}
