import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// An enum to define the type of file that
///  needs to be picked for a feature workflow.
// ignore: public_member_api_docs
enum PickType { singleImage, multiImage, pdf }

/// A central screen that provides entry points
///  to all the document processing features.
///
/// This screen is useful for development and testing, allowing quick access to
/// each isolated workflow.
class FeatureTestHubScreen extends ConsumerWidget {
  /// Creates an instance of [FeatureTestHubScreen].
  const FeatureTestHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Select a Workflow',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _FeatureButton(
            title: AppConstants.titleResizeImage,
            path: AppConstants.routeResize,
            pickType: PickType.singleImage,
          ),
          _FeatureButton(
            title: AppConstants.titleCompressImage,
            path: AppConstants.routeCompress,
            pickType: PickType.singleImage,
          ),
          _FeatureButton(
            title: AppConstants.titleCropEditImage,
            path: AppConstants.routeEdit,
            pickType: PickType.singleImage,
          ),
          _FeatureButton(
            title: AppConstants.titleChangeImageFormat,
            path: AppConstants.routeImageFormat,
            pickType: PickType.singleImage,
          ),
          _FeatureButton(
            title: AppConstants.titleImagesToPdf,
            path: AppConstants.routeImagesToPdf,
            pickType: PickType.multiImage,
          ),
          _FeatureButton(
            title: AppConstants.titlePdfToImages,
            path: AppConstants.routePdfToImages,
            pickType: PickType.pdf,
          ),
          _FeatureButton(
            title: AppConstants.titleCompressPdf,
            path: AppConstants.routePdfCompression,
            pickType: PickType.pdf,
          ),
          _FeatureButton(
            title: AppConstants.titlePdfSecurity,
            path: AppConstants.routePdfSecurity,
            pickType: PickType.pdf,
          ),
        ],
      ),
    );
  }
}

/// A private helper widget for a single button on the hub screen.
///
/// It handles the logic for picking the appropriate file type and then
/// navigating to the specified feature screen with
/// the picked file as an argument.
class _FeatureButton extends ConsumerWidget {
  /// Creates an instance of [_FeatureButton].
  const _FeatureButton({
    required this.title,
    required this.path,
    required this.pickType,
  });

  /// The text to display on the button.
  final String title;

  /// The route path to navigate to.
  final String path;

  /// The type of file to pick before navigating.
  final PickType pickType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          textStyle: const TextStyle(fontSize: 16),
        ),
        child: Text(title),
        onPressed: () async {
          // Reading the repository here is safe as
          // it's within an async callback.
          final repo = await ref.read(documentRepositoryProvider.future);

          // Use a switch statement to handle the different file picking logic.
          switch (pickType) {
            case PickType.singleImage:
              final (pickedFile, wasConverted) = await repo.pickImage();
              if (pickedFile != null && context.mounted) {
                if (wasConverted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unsupported format was converted to JPG.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
                await context.push(path, extra: pickedFile);
              }
            case PickType.multiImage:
              final pickedFiles = await repo
                  .pickAndSanitizeMultipleImagesForPdf();
              if (pickedFiles.isNotEmpty && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Images sanitized and ready for PDF conversion.',
                    ),
                    backgroundColor: Colors.blue,
                  ),
                );
                await context.push(path, extra: pickedFiles);
              }
            case PickType.pdf:
              final pickedFile = await repo.pickPdf();
              if (pickedFile != null && context.mounted) {
                await context.push(path, extra: pickedFile);
              }
          }
        },
      ),
    );
  }
}
