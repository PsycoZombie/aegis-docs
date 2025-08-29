import 'package:aegis_docs/data/models/wallet_item.dart';
import 'package:aegis_docs/features/home/widgets/item_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A card widget that represents a single folder in the wallet's grid view.
class FolderCard extends ConsumerWidget {
  /// Creates an instance of [FolderCard].
  const FolderCard({required this.folder, this.isSelected = false, super.key});

  /// The folder data model to display.
  final FolderModel folder;

  /// Whether the folder is selected or not
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      color: isSelected ? theme.primaryColor.withAlpha(77) : null,
      shape: isSelected
          ? RoundedRectangleBorder(
              side: BorderSide(color: theme.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.folder, size: 50, color: Colors.amber),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 4,
                  ),
                  child: Text(
                    folder.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
                        folder.path,
                        isFolder: true,
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
