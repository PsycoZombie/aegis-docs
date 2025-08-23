import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

/// A widget that displays a grid of images that
/// can be reordered via drag-and-drop
/// and allows for individual items to be removed.
class ReorderableImageGrid extends StatelessWidget {
  /// Creates an instance of [ReorderableImageGrid].
  const ReorderableImageGrid({
    required this.images,
    required this.onReorder,
    required this.onRemove,
    super.key,
  });

  /// The list of image models to display in the grid.
  final List<PickedFileModel> images;

  /// A callback function that is invoked when
  /// the user finishes reordering an item.
  /// It provides the old and new indices of the moved item.
  final void Function(int oldIndex, int newIndex) onReorder;

  /// A callback function that is invoked when the
  /// user taps the remove button on an item.
  /// It provides the index of the item to be removed.
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    return ReorderableGridView.builder(
      itemCount: images.length,
      onReorder: onReorder,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final image = images[index];
        return Card(
          // A ValueKey is crucial for reorderable lists
          // to correctly identify widgets.
          key: ValueKey(image.hashCode),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(image.bytes!, fit: BoxFit.contain),
              // Close button to remove the image from the list.
              Positioned(
                top: 4,
                right: 4,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 14,
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => onRemove(index),
                  ),
                ),
              ),
              // A label showing the image's current position in the order.
              Positioned(
                bottom: 4,
                left: 4,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.black54,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
