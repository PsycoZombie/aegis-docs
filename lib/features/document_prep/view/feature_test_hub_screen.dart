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
            title: 'Resize Image',
            path: '/hub/resize',
            pickType: PickType.singleImage,
          ),
          _FeatureButton(
            title: 'Compress Image',
            path: '/hub/compress',
            pickType: PickType.singleImage,
          ),
          _FeatureButton(
            title: 'Crop & Edit Image',
            path: '/hub/edit',
            pickType: PickType.singleImage,
          ),
          _FeatureButton(
            title: 'Change Image Format',
            path: '/hub/image-format',
            pickType: PickType.singleImage,
          ),
          _FeatureButton(
            title: 'Images to PDF',
            path: '/hub/images-to-pdf',
            pickType: PickType.multiImage,
          ),
          _FeatureButton(
            title: 'PDF to Images',
            path: '/hub/pdf-to-images',
            pickType: PickType.pdf,
          ),
          _FeatureButton(
            title: 'Compress PDF (Native)',
            path: '/hub/pdf-compression',
            pickType: PickType.pdf,
          ),
          _FeatureButton(
            title: 'PDF Security',
            path: '/hub/pdf-security',
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
