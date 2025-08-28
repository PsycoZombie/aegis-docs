import 'dart:typed_data';

import 'package:aegis_docs/shared_widgets/full_screen_image_view.dart';
import 'package:flutter/material.dart';

/// A widget that displays a grid of images,
/// allowing the user to select multiple items.
class SelectableImageGrid extends StatelessWidget {
  /// Creates an instance of [SelectableImageGrid].
  const SelectableImageGrid({
    required this.images,
    required this.selectedIndices,
    required this.onImageTap,
    super.key,
  });

  /// The list of image data to display in the grid.
  final List<Uint8List> images;

  /// A set of integers representing the
  /// indices of the currently selected images.
  final Set<int> selectedIndices;

  /// A callback function that is invoked when an image in the grid is tapped.
  /// It provides the index of the tapped image.
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
        // A unique tag for the Hero animation, based on the image's hash code.
        final heroTag = 'pdf_image_${imageBytes.hashCode}';

        return GridTile(
          child: GestureDetector(
            onTap: () => onImageTap(index),
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: isSelected ? 6 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                // Apply a colored border to visually indicate selection.
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
                  // Show a checkmark icon on selected images.
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
                  // Display the page number at the bottom of the image.
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
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ),
                  // A small button to view the image in full screen.
                  Positioned(
                    bottom: 24, // Positioned above the page number text
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
