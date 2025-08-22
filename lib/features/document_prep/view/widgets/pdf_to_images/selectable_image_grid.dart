import 'dart:typed_data';

import 'package:aegis_docs/shared_widgets/full_screen_image_view.dart';
import 'package:flutter/material.dart';

class SelectableImageGrid extends StatelessWidget {
  const SelectableImageGrid({
    required this.images,
    required this.selectedIndices,
    required this.onImageTap,
    super.key,
  });
  final List<Uint8List> images;
  final Set<int> selectedIndices;
  final void Function(int index) onImageTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final imageBytes = images[index];
        final isSelected = selectedIndices.contains(index);
        final heroTag = 'pdf_image_${imageBytes.hashCode}';

        return GridTile(
          child: GestureDetector(
            onTap: () => onImageTap(index),
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: isSelected ? 6 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroTag,
                    child: Image.memory(imageBytes, fit: BoxFit.contain),
                  ),
                  if (isSelected)
                    const Positioned(
                      top: 4,
                      right: 4,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      color: Colors.black54,
                      child: Text(
                        'Page ${index + 1}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 14,
                        icon: const Icon(Icons.fullscreen, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<dynamic>(
                              builder: (_) => FullScreenImageView(
                                imageBytes: imageBytes,
                                heroTag: heroTag,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
