import 'dart:io';

import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/password_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

/// A screen that displays the content of a single decrypted document.
///
/// It determines whether to show a PDF viewer or an image viewer based on the
/// file extension.
class DocumentDetailScreen extends ConsumerStatefulWidget {
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
  ConsumerState<DocumentDetailScreen> createState() =>
      _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  File? _tempPdfFile;

  @override
  void dispose() {
    _deleteTempFile();
    super.dispose();
  }

  Future<void> _deleteTempFile() async {
    try {
      if (_tempPdfFile != null && await _tempPdfFile!.exists()) {
        await _tempPdfFile!.delete();
      }
    } on Object catch (e) {
      debugPrint('Error deleting temporary PDF file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPdf = widget.fileName.toLowerCase().endsWith('.pdf');

    return AppScaffold(
      title: widget.fileName,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: isPdf ? _buildPdfViewer() : _buildImageViewer(),
        ),
      ),
    );
  }

  Widget _buildPdfViewer() {
    final pdfFileAsyncValue = ref.watch(
      decryptedDocumentFileProvider(
        (fileName: widget.fileName, folderPath: widget.folderPath),
      ),
    );

    return pdfFileAsyncValue.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error creating temp file: $error'),
      data: (pdfFile) {
        _tempPdfFile = pdfFile;
        return Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: PdfViewer.file(
            pdfFile.path,
            passwordProvider: () => showPasswordDialog(context),
            // Using the correct parameters from the signature you provided.
            params: PdfViewerParams(
              verticalCacheExtent: 3,
              loadingBannerBuilder: (context, pagesLoaded, totalPages) {
                return const Center(child: CircularProgressIndicator());
              },
              errorBannerBuilder: (context, error, stackTrace, documentRef) {
                // Handle password cancellation gracefully
                if (error is PdfPasswordException) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Password is required to view this document.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error loading document: $error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageViewer() {
    final imageAsyncValue = ref.watch(
      documentDetailProvider(
        fileName: widget.fileName,
        folderPath: widget.folderPath,
      ),
    );

    return imageAsyncValue.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error loading image: $error'),
      data: (decryptedData) {
        if (decryptedData == null) {
          return const Text('Could not load the image.');
        }
        return Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InteractiveViewer(
            child: Image.memory(decryptedData, fit: BoxFit.contain),
          ),
        );
      },
    );
  }
}
