import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/features/document_prep/providers/pdf_to_images_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/pdf_to_images/selectable_image_grid.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/multi_save_options_dialog.dart';
import 'package:aegis_docs/shared_widgets/password_dialog.dart';
import 'package:aegis_docs/shared_widgets/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:pdfrx/pdfrx.dart';

/// A screen for converting a selected PDF document into a series of images.
class PdfToImagesScreen extends ConsumerStatefulWidget {
  /// Creates an instance of [PdfToImagesScreen].
  const PdfToImagesScreen({super.key, this.initialFile});

  /// The initial PDF file to be processed, passed from the previous screen.
  final PickedFileModel? initialFile;

  @override
  ConsumerState<PdfToImagesScreen> createState() => _PdfToImagesScreenState();
}

class _PdfToImagesScreenState extends ConsumerState<PdfToImagesScreen> {
  // Flag to prevent showing the dialog multiple times for the same error.
  bool _isPasswordDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    final viewModelProvider = pdfToImagesViewModelProvider(widget.initialFile);
    final viewModel = ref.watch(viewModelProvider);
    final notifier = ref.read(viewModelProvider.notifier);

    // ADDED: ref.listen to handle side-effects like showing dialogs.
    ref.listen<AsyncValue<PdfToImagesState>>(
      viewModelProvider,
      // The listener gives us the previous and next states.
      (previous, next) {
        // --- THIS IS THE FIX ---
        // Only show the dialog if the state TRANSITIONS to an error state.
        // This prevents it from re-triggering on a loading state that still
        // contains a reference to the old error.
        if (previous is! AsyncError &&
            next is AsyncError &&
            !_isPasswordDialogShowing) {
          // --- END OF FIX ---

          final error = next.error;
          if (error is pdfrx.PdfPasswordException) {
            // Use the prefix here
            setState(() {
              _isPasswordDialogShowing = true;
            });

            showPasswordDialog(context).then((password) {
              setState(() {
                _isPasswordDialogShowing = false;
              });

              if (password != null && password.isNotEmpty) {
                notifier.convertToImages(password: password);
              }
            });
          }
        }
      },
    );

    return AppScaffold(
      title: AppConstants.titlePdfToImages,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: viewModel.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) {
            debugPrint('An error occurred: $err');
            // Gracefully handle password error UI to avoid showing a generic error text
            if (err is PdfPasswordException) {
              return _buildContent(
                context,
                viewModel.value!,
                notifier,
                viewModel,
                ref,
              );
            }
            return Center(child: Text('An error occurred from pdfrx: $err'));
          },
          data: (state) {
            if (state.originalPdf == null) {
              return const Center(
                child: Text('No PDF was selected. Please go back.'),
              );
            }
            return _buildContent(context, state, notifier, viewModel, ref);
          },
        ),
      ),
    );
  }

  /// Builds the main content of the screen based on the current state.
  Widget _buildContent(
    BuildContext context,
    PdfToImagesState state,
    PdfToImagesViewModel notifier,
    AsyncValue<PdfToImagesState> viewModel, // Pass the full AsyncValue
    WidgetRef ref,
  ) {
    // Determine if any operation is in progress by
    // checking the provider's state.
    final isProcessing = viewModel.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text(
              state.originalPdf!.name,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: const Text('Selected PDF'),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: state.generatedImages.isEmpty
              ? Center(
                  child: FilledButton.icon(
                    icon: isProcessing
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.transform),
                    label: Text(
                      isProcessing ? 'Converting...' : 'Convert to Images',
                    ),
                    onPressed: isProcessing ? null : notifier.convertToImages,
                  ),
                )
              : SelectableImageGrid(
                  images: state.generatedImages,
                  selectedIndices: state.selectedImageIndices,
                  onImageTap: notifier.toggleImageSelection,
                ),
        ),
        if (state.generatedImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: isProcessing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_alt_outlined),
            label: Text(
              isProcessing
                  ? 'Saving...'
                  : 'Save Selected (${state.selectedImageIndices.length})',
            ),
            onPressed: isProcessing || state.selectedImageIndices.isEmpty
                ? null
                : () async {
                    final defaultName = p.basenameWithoutExtension(
                      state.originalPdf!.name,
                    );

                    final saveResult = await showMultiSaveOptionsDialog(
                      context,
                      defaultBaseName: defaultName,
                      fileCount: state.selectedImageIndices.length,
                    );

                    if (saveResult != null && context.mounted) {
                      await notifier.saveSelectedImages(
                        baseName: saveResult.baseName,
                        folderPath: saveResult.folderPath,
                      );
                      if (context.mounted) {
                        showToast(
                          context,
                          'Saved ${state.selectedImageIndices.length}'
                          ' images!',
                        );
                        ref.invalidate(walletViewModelProvider);
                        context.pop();
                      }
                    }
                  },
          ),
        ],
      ],
    );
  }
}
