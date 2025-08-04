import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class ReorderableImageGrid extends StatelessWidget {
  final List<PickedFile> images;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index) onRemove;

  const ReorderableImageGrid({
    super.key,
    required this.images,
    required this.onReorder,
    required this.onRemove,
  });

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
          key: ValueKey(image.hashCode),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(image.bytes, fit: BoxFit.contain),
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
