// import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
// import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart'; // Import GoRouter

// class HomeScreen extends ConsumerWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = Theme.of(context);
//     final textTheme = theme.textTheme;
//     final colorScheme = theme.colorScheme;

//     return AppScaffold(
//       title: 'Aegis Docs',
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.logout),
//           onPressed: () {
//             ref.read(localAuthProvider.notifier).logout();
//           },
//         ),
//       ],
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.wallet_outlined, color: colorScheme.primary),
//               const SizedBox(width: 8),
//               Text('My Wallet', style: textTheme.headlineSmall),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Expanded(
//             flex: 1,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: colorScheme.surfaceContainerHighest.withAlpha(128),
//                 border: Border.all(color: colorScheme.outline.withAlpha(128)),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: const Center(
//                 child: Text('Your saved documents will appear here.'),
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),

//           Row(
//             children: [
//               Icon(Icons.people_outline, color: colorScheme.primary),
//               const SizedBox(width: 8),
//               Text('Profiles', style: textTheme.headlineSmall),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Expanded(
//             flex: 1,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: colorScheme.surfaceContainerHighest.withAlpha(128),
//                 border: Border.all(color: colorScheme.outline.withAlpha(51)),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: const Center(
//                 child: Text('User profiles will appear here.'),
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           context.push('/prep');
//         },
//         label: const Text('Start New Prep'),
//         icon: const Icon(Icons.add),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../document_prep/view/widgets/test_image_compress_widget.dart';
import '../../document_prep/view/widgets/test_image_crop_widget.dart';
import '../../document_prep/view/widgets/test_image_format_widget.dart';
// Import all the test widgets we are about to create.
// You will see errors here until all files are created.
import '../../document_prep/view/widgets/test_image_picker_widget.dart';
import '../../document_prep/view/widgets/test_image_resize_widget.dart';
import '../../document_prep/view/widgets/test_image_to_pdf_widget.dart';
import '../../document_prep/view/widgets/test_native_compression_widget.dart';
import '../../document_prep/view/widgets/test_pdf_picker_widget.dart';
import '../../document_prep/view/widgets/test_pdf_to_images_widget.dart';

class FeatureTestHubScreen extends StatelessWidget {
  const FeatureTestHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aegis Docs Feature Tests')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _FeatureButton(
            title: '1. Pick Image',
            child: const TestImagePickerWidget(),
          ),
          _FeatureButton(
            title: '2. Pick PDF',
            child: const TestPdfPickerWidget(),
          ),
          _FeatureButton(
            title: '3. Resize Image',
            child: const TestImageResizeWidget(),
          ),
          _FeatureButton(
            title: '4. Compress Image',
            child: const TestImageCompressWidget(),
          ),
          _FeatureButton(
            title: '5. Crop Image',
            child: const TestImageCropWidget(),
          ),
          _FeatureButton(
            title: '6. Change Image Format',
            child: const TestImageFormatWidget(),
          ),
          _FeatureButton(
            title: '7. Convert Image to PDF',
            child: const TestImageToPdfWidget(),
          ),
          _FeatureButton(
            title: '8. Convert PDF to Images',
            child: const TestPdfToImagesWidget(),
          ),
          _FeatureButton(
            title: '9. Native PDF Compression',
            child: const TestNativeCompressionWidget(),
          ),
        ],
      ),
    );
  }
}

// Helper widget to avoid boilerplate
class _FeatureButton extends StatelessWidget {
  final String title;
  final Widget child;

  const _FeatureButton({required this.title, required this.child});

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
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: Text(title)),
                body: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
