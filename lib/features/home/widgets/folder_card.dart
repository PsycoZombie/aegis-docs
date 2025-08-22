import 'dart:io';

import 'package:aegis_docs/features/home/providers/home_provider.dart';
import 'package:aegis_docs/features/home/widgets/item_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class FolderCard extends ConsumerWidget {
  const FolderCard({required this.folder, super.key});
  final Directory folder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderName = p.basename(folder.path);
    final homeNotifier = ref.read(homeViewModelProvider.notifier);
    final homeState = ref.watch(homeViewModelProvider);
    final folderPath = homeState.currentFolderPath == null
        ? folderName
        : p.join(homeState.currentFolderPath!, folderName);

    return GestureDetector(
      onTap: () => homeNotifier.navigateToFolder(folderName),
      onLongPress: () =>
          showContextMenu(context, ref, folderPath, isFolder: true),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder, size: 50, color: Colors.amber),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                folderName,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
