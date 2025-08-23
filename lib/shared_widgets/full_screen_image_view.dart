import 'dart:typed_data';

import 'package:flutter/material.dart';

/// A screen that displays a single image in full-screen mode, allowing for
/// panning and zooming.
class FullScreenImageView extends StatelessWidget {
  /// Creates an instance of [FullScreenImageView].
  const FullScreenImageView({
    required this.imageBytes,
    required this.heroTag,
    super.key,
  });

  /// The raw byte data of the image to be displayed.
  final Uint8List imageBytes;

  /// A unique tag that connects this view with a thumbnail in a previous screen
  /// for a smooth hero animation.
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        // Tapping anywhere on the screen dismisses the view.
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Hero(
            tag: heroTag,
            child: InteractiveViewer(
              // InteractiveViewer provides pan and zoom capabilities.
              child: Image.memory(imageBytes),
            ),
          ),
        ),
      ),
    );
  }
}
