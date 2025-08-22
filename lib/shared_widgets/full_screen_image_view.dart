import 'dart:typed_data';

import 'package:flutter/material.dart';

class FullScreenImageView extends StatelessWidget {

  const FullScreenImageView({
    required this.imageBytes, required this.heroTag, super.key,
  });
  final Uint8List imageBytes;
  final String heroTag;

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
