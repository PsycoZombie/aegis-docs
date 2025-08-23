import 'package:aegis_docs/data/models/wallet_item.dart';
import 'package:aegis_docs/features/home/providers/home_provider.dart';
import 'package:aegis_docs/features/home/widgets/item_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A card widget that represents a single folder in the wallet's grid view.
class FolderCard extends ConsumerWidget {
  /// Creates an instance of [FolderCard].
  const FolderCard({required this.folder, super.key});

  /// The folder data model to display.
  final FolderModel folder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeNotifier = ref.read(homeViewModelProvider.notifier);

    return GestureDetector(
      // Tapping navigates into the folder.
      onTap: () => homeNotifier.navigateToFolder(folder.name),
      // Long-pressing shows the context menu for
      // actions like rename and delete.
      onLongPress: () =>
          showContextMenu(context, ref, folder.path, isFolder: true),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder, size: 50, color: Colors.amber),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                folder.name,
                textAlign: TextAlign.center,
                maxLines: 2, // Allow for two lines for longer names
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
