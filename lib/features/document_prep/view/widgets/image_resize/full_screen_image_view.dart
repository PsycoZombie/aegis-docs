import 'dart:typed_data';

import 'package:flutter/material.dart';

class FullScreenImageView extends StatelessWidget {
  final Uint8List imageBytes;
  final String heroTag;

  const FullScreenImageView({
    super.key,
    required this.imageBytes,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Hero(
            tag: heroTag,
            child: InteractiveViewer(child: Image.memory(imageBytes)),
          ),
        ),
      ),
    );
  }
}
