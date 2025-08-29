import 'package:aegis_docs/data/models/wallet_item.dart';
import 'package:aegis_docs/features/home/widgets/item_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A card widget that represents a single document in the wallet's grid view.
class DocumentCard extends ConsumerWidget {
  /// Creates an instance of [DocumentCard].
  const DocumentCard({required this.file, this.isSelected = false, super.key});

  /// The document data model to display.
  final DocumentModel file;

  /// Whether the document is selected or not.
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPdf = file.name.toLowerCase().endsWith('.pdf');
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      color: isSelected ? theme.primaryColor.withAlpha(77) : null,
      shape: isSelected
          ? RoundedRectangleBorder(
              side: BorderSide(color: theme.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Stack(
        children: [
          GridTile(
            footer: GridTileBar(
              backgroundColor: Colors.black45,
              title: Text(file.name, overflow: TextOverflow.ellipsis),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf : Icons.image,
              size: 60,
              color: isPdf ? Colors.red.shade300 : Colors.blue.shade300,
            ),
          ),
          if (isSelected)
            Positioned(
              top: 4,
              right: 4,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: theme.primaryColor,
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ),
          // The "more" button for single-item actions.
          // It's hidden when the item is selected to reduce clutter.
          if (!isSelected)
            Positioned(
              top: 4,
              right: 4,
              child: Builder(
                builder: (BuildContext builderContext) {
                  return IconButton(
                    icon: const Icon(Icons.more_vert),
                    tooltip: 'More options',
                    onPressed: () {
                      showContextMenu(
                        builderContext,
                        ref,
                        file.path,
                        isFolder: false,
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
