import 'package:flutter/material.dart';

import '../../document_prep/view/widgets/test_image_compress_widget.dart';
import '../../document_prep/view/widgets/test_image_crop_widget.dart';
import '../../document_prep/view/widgets/test_image_format_widget.dart';
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
