// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../providers/document_providers.dart';

// class TestImageCropWidget extends ConsumerStatefulWidget {
//   const TestImageCropWidget({super.key});

//   @override
//   ConsumerState<TestImageCropWidget> createState() =>
//       _TestImageCropWidgetState();
// }

// class _TestImageCropWidgetState extends ConsumerState<TestImageCropWidget> {
//   // We only need one state for the image bytes, which will be updated after cropping.
//   Uint8List? _imageBytes;
//   bool _isLoading = false;

//   Future<void> _pickImage() async {
//     setState(() {
//       _imageBytes = null;
//       _isLoading = true;
//     });

//     try {
//       final image = await ref.read(documentRepositoryProvider).pickImage();
//       setState(() {
//         _imageBytes = image?.bytes;
//       });
//     } catch (e) {
//       _showError('Error picking image: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _cropImage() async {
//     if (_imageBytes == null) return;

//     setState(() => _isLoading = true);
//     try {
//       // The cropImage method can return null if the user cancels the operation.
//       final result = await ref
//           .read(documentRepositoryProvider)
//           .cropImage(_imageBytes!);

//       if (result != null) {
//         setState(() {
//           _imageBytes = result;
//         });
//       }
//     } catch (e) {
//       _showError('Error cropping image: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         if (_isLoading) const CircularProgressIndicator(),

//         if (_imageBytes == null && !_isLoading)
//           ElevatedButton(
//             onPressed: _pickImage,
//             child: const Text('1. Pick an Image'),
//           ),

//         if (_imageBytes != null) ...[
//           const Text(
//             'Current Image',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           Image.memory(_imageBytes!, height: 250, fit: BoxFit.contain),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: _isLoading ? null : _cropImage,
//             child: const Text('2. Crop Image'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await ref
//                   .read(documentRepositoryProvider)
//                   .saveEncryptedDocument(
//                     data: _imageBytes!,
//                     fileName: 'cropped_image.jpg',
//                   );
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Cropped image saved!')),
//               );
//             },
//             child: const Text('Save Cropped Image'),
//           ),
//         ],
//       ],
//     );
//   }
// }
