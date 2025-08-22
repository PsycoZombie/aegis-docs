import 'package:aegis_docs/features/home/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showContextMenu(
  BuildContext context,
  WidgetRef ref,
  String path, {
  required bool isFolder,
}) {
  final homeNotifier = ref.read(homeViewModelProvider.notifier);
  final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
  final button = context.findRenderObject()! as RenderBox;
  final position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(Offset.zero, ancestor: overlay),
      button.localToGlobal(
        button.size.bottomRight(Offset.zero),
        ancestor: overlay,
      ),
    ),
    Offset.zero & overlay.size,
  );

  showMenu<String>(
    context: context,
    position: position,
    items: [
      if (!isFolder) ...[
        const PopupMenuItem<String>(
          value: 'export',
          child: ListTile(
            leading: Icon(Icons.save_alt),
            title: Text('Export to Device'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'share',
          child: ListTile(leading: Icon(Icons.share), title: Text('Share')),
        ),
        const PopupMenuDivider(),
      ],
      const PopupMenuItem<String>(
        value: 'rename',
        child: ListTile(leading: Icon(Icons.edit), title: Text('Rename')),
      ),
      const PopupMenuItem<String>(
        value: 'delete',
        child: ListTile(
          leading: Icon(Icons.delete_outline, color: Colors.red),
          title: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ),
    ],
  ).then((String? value) {
    if (value == null) return;
    switch (value) {
      case 'rename':
        if (context.mounted) {
          homeNotifier.renameItem(context, path, isFolder: isFolder);
        }
      case 'delete':
        if (context.mounted) {
          homeNotifier.deleteItem(context, path, isFolder: isFolder);
        }
      case 'export':
        homeNotifier.exportDocument(path);
      case 'share':
        homeNotifier.shareDocument(path);
    }
  });
}
