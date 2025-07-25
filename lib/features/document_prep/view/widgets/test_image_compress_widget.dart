// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../../data/models/picked_file_model.dart';
// import '../../providers/document_providers.dart';

// class TestImageCompressWidget extends ConsumerStatefulWidget {
//   const TestImageCompressWidget({super.key});

//   @override
//   ConsumerState<TestImageCompressWidget> createState() =>
//       _TestImageCompressWidgetState();
// }

// class _TestImageCompressWidgetState
//     extends ConsumerState<TestImageCompressWidget> {
//   PickedFile? _originalImage;
//   Uint8List? _compressedImage;
//   bool _isLoading = false;
//   double _quality = 85.0;

//   Future<void> _pickImage() async {
//     setState(() {
//       _originalImage = null;
//       _compressedImage = null;
//       _isLoading = true;
//     });

//     try {
//       final image = await ref.read(documentRepositoryProvider).pickImage();
//       setState(() {
//         _originalImage = image;
//       });
//     } catch (e) {
//       _showError('Error picking image: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _compressImage() async {
//     if (_originalImage == null) return;

//     setState(() => _isLoading = true);
//     try {
//       final result = await ref
//           .read(documentRepositoryProvider)
//           .compressImage(_originalImage!.bytes, quality: _quality.toInt());
//       setState(() {
//         _compressedImage = result;
//       });
//     } catch (e) {
//       _showError('Error compressing image: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }

//   String _formatSize(int bytes) => '${(bytes / 1024).toStringAsFixed(2)} KB';

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         if (_isLoading) const CircularProgressIndicator(),

//         if (_originalImage == null && !_isLoading)
//           ElevatedButton(
//             onPressed: _pickImage,
//             child: const Text('1. Pick an Image'),
//           ),

//         if (_originalImage != null) ...[
//           const Text(
//             'Original Image',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Image.memory(_originalImage!.bytes, height: 150, fit: BoxFit.contain),
//           Text('Size: ${_formatSize(_originalImage!.bytes.lengthInBytes)}'),
//           const SizedBox(height: 20),

//           if (_compressedImage != null) ...[
//             const Text(
//               'Compressed Image',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Image.memory(_compressedImage!, height: 150, fit: BoxFit.contain),
//             Text('Size: ${_formatSize(_compressedImage!.lengthInBytes)}'),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 await ref
//                     .read(documentRepositoryProvider)
//                     .saveEncryptedDocument(
//                       data: _compressedImage!,
//                       fileName: 'compressed_image.jpg',
//                     );
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Compressed image saved!')),
//                 );
//               },
//               child: const Text('Save Compressed Image'),
//             ),
//           ],

//           Text('Quality: ${_quality.toInt()}'),
//           Slider(
//             value: _quality,
//             min: 10,
//             max: 100,
//             divisions: 9,
//             label: _quality.toInt().toString(),
//             onChanged: (value) {
//               setState(() {
//                 _quality = value;
//               });
//             },
//           ),
//           ElevatedButton(
//             onPressed: _isLoading ? null : _compressImage,
//             child: const Text('2. Compress Image'),
//           ),
//         ],
//       ],
//     );
//   }
// }
