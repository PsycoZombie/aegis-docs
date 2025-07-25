// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../../data/models/picked_file_model.dart';
// import '../../providers/document_providers.dart';

// class TestPdfToImagesWidget extends ConsumerStatefulWidget {
//   const TestPdfToImagesWidget({super.key});

//   @override
//   ConsumerState<TestPdfToImagesWidget> createState() =>
//       _TestPdfToImagesWidgetState();
// }

// class _TestPdfToImagesWidgetState extends ConsumerState<TestPdfToImagesWidget> {
//   PickedFile? _originalPdf;
//   List<Uint8List> _generatedImages = [];
//   bool _isLoading = false;

//   Future<void> _pickPdf() async {
//     setState(() {
//       _originalPdf = null;
//       _generatedImages = [];
//       _isLoading = true;
//     });

//     try {
//       final pdf = await ref.read(documentRepositoryProvider).pickPdf();
//       setState(() {
//         _originalPdf = pdf;
//       });
//     } catch (e) {
//       _showError('Error picking PDF: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _convertToImages() async {
//     if (_originalPdf == null) return;

//     setState(() => _isLoading = true);
//     try {
//       final result = await ref
//           .read(documentRepositoryProvider)
//           .convertPdfToImages(_originalPdf!.bytes);
//       setState(() {
//         _generatedImages = result;
//       });
//     } catch (e) {
//       _showError('Error converting to images: $e');
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

//         if (_originalPdf == null && !_isLoading)
//           ElevatedButton(
//             onPressed: _pickPdf,
//             child: const Text('1. Pick a PDF'),
//           ),

//         if (_originalPdf != null) ...[
//           const Icon(Icons.picture_as_pdf, color: Colors.red, size: 80),
//           Text(_originalPdf!.name),
//           const SizedBox(height: 20),

//           if (_generatedImages.isNotEmpty) ...[
//             ElevatedButton(
//               onPressed: () async {
//                 for (int i = 0; i < _generatedImages.length; i++) {
//                   await ref
//                       .read(documentRepositoryProvider)
//                       .saveEncryptedDocument(
//                         data: _generatedImages[i],
//                         fileName: 'pdf_page_${i + 1}.png',
//                       );
//                 }
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Saved ${_generatedImages.length} images!'),
//                   ),
//                 );
//               },
//               child: const Text('Save All Images'),
//             ),
//             Text(
//               'Generated ${_generatedImages.length} Images:',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             SizedBox(
//               height: 200,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: _generatedImages.length,
//                 separatorBuilder: (context, index) => const SizedBox(width: 10),
//                 itemBuilder: (context, index) {
//                   return Image.memory(
//                     _generatedImages[index],
//                     fit: BoxFit.contain,
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],

//           ElevatedButton(
//             onPressed: _isLoading ? null : _convertToImages,
//             child: const Text('2. Convert to Images'),
//           ),
//         ],
//       ],
//     );
//   }
// }
