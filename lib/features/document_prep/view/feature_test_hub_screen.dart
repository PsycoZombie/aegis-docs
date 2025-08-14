import 'package:aegis_docs/features/document_prep/providers/document_providers.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum PickType { singleImage, multiImage, pdf }

class FeatureTestHubScreen extends ConsumerWidget {
  const FeatureTestHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Select a Workflow',
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _FeatureButton(
            title: 'Resize Image',
            path: '/hub/resize',
            ref: ref,
            pickType: PickType.singleImage,
          ),
          _FeatureButton(
            title: 'Compress Image',
            path: '/hub/compress',
            ref: ref,
            pickType: PickType.singleImage,
          ),
          _FeatureButton(
            title: 'Crop & Edit Image',
            path: '/hub/edit',
            ref: ref,
            pickType: PickType.singleImage,
          ),
          _FeatureButton(
            title: 'Change Image Format',
            path: '/hub/image-format',
            ref: ref,
            pickType: PickType.singleImage,
          ),
          _FeatureButton(
            title: 'Images to PDF',
            path: '/hub/images-to-pdf',
            ref: ref,
            pickType: PickType.multiImage,
          ),
          _FeatureButton(
            title: 'PDF to Images',
            path: '/hub/pdf-to-images',
            ref: ref,
            pickType: PickType.pdf,
          ),
          _FeatureButton(
            title: 'Compress PDF (Native)',
            path: '/hub/pdf-compression',
            ref: ref,
            pickType: PickType.pdf,
          ),
          _FeatureButton(
            title: 'PDF Security',
            path: '/hub/pdf-security',
            ref: ref,
            pickType: PickType.pdf,
          ),
        ],
      ),
    );
  }
}

class _FeatureButton extends StatelessWidget {
  final String title;
  final String path;
  final WidgetRef ref;
  final PickType pickType;

  const _FeatureButton({
    required this.title,
    required this.path,
    required this.ref,
    required this.pickType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          textStyle: const TextStyle(fontSize: 16),
        ),
        child: Text(title),
        onPressed: () async {
          final repo = await ref.read(documentRepositoryProvider.future);

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
                context.push(path, extra: pickedFile);
              }
              break;
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
                context.push(path, extra: pickedFiles);
              }
              break;
            case PickType.pdf:
              final pickedFile = await repo.pickPdf();
              if (pickedFile != null && context.mounted) {
                context.push(path, extra: pickedFile);
              }
              break;
          }
        },
      ),
    );
  }
}
