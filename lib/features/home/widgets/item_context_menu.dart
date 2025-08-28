import 'package:aegis_docs/core/services/haptics_service.dart';
import 'package:aegis_docs/features/home/providers/home_provider.dart';
import 'package:aegis_docs/shared_widgets/rename_dialog.dart';
import 'package:aegis_docs/shared_widgets/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

/// Shows a context-sensitive popup menu for a given file or folder.
///
/// This function is typically called from a
/// `GestureDetector`'s `onLongPress` callback.
/// It handles the UI for the menu and orchestrates
/// the appropriate action by calling
/// the [HomeViewModel].
void showContextMenu(
  BuildContext context,
  WidgetRef ref,
  String path, {
  required bool isFolder,
}) {
  final homeNotifier = ref.read(homeViewModelProvider.notifier);
  final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
  final button = context.findRenderObject()! as RenderBox;

  final haptics = ref.read(hapticsProvider)..lightImpact();

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
  ).then((String? value) async {
    if (value == null || !context.mounted) return;
    switch (value) {
      case 'rename':
        await haptics.selectionClick();
        if (context.mounted) {
          await _handleRename(context, homeNotifier, path, isFolder: isFolder);
        }
      case 'delete':
        await haptics.heavyImpact();
        if (context.mounted) {
          await _handleDelete(context, homeNotifier, path, isFolder: isFolder);
        }
      case 'export':
        await haptics.selectionClick();
        final errorMessage = await homeNotifier.exportDocument(
          p.basename(path),
        );
        if (context.mounted) {
          if (errorMessage != null) {
            showToast(context, errorMessage, type: ToastType.error);
          } else {
            showToast(context, 'File exported successfully!');
          }
        }
      case 'share':
        await haptics.selectionClick();
        final errorMessage = await homeNotifier.shareDocument(p.basename(path));
        if (context.mounted && errorMessage != null) {
          showToast(context, errorMessage, type: ToastType.error);
        }
    }
  });
}

/// A helper function to handle the rename action.
Future<void> _handleRename(
  BuildContext context,
  HomeViewModel notifier,
  String path, {
  required bool isFolder,
}) async {
  final currentName = isFolder
      ? p.basename(path)
      : p.basenameWithoutExtension(path);

  // 1. Show the rename dialog and get the new name from the user.
  final newName = await showRenameDialog(
    context,
    currentName: currentName,
    title: isFolder ? 'Rename Folder' : 'Rename File',
  );

  // 2. If a valid new name was entered, call the notifier with the data.
  if (newName != null && newName.isNotEmpty && newName != currentName) {
    await notifier.renameItem(path, newName, isFolder: isFolder);
  }
}

/// A helper function to handle the delete action.
Future<void> _handleDelete(
  BuildContext context,
  HomeViewModel notifier,
  String path, {
  required bool isFolder,
}) async {
  final name = p.basename(path);

  // 1. Show a confirmation dialog.
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(isFolder ? 'Delete Folder?' : 'Delete Document?'),
      content: Text(
        'Are you sure you want to delete "$name"?\n'
        '${isFolder ? 'This will delete all contents inside.' : ''}'
        '\nThis action cannot be undone.',
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        TextButton(
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  );

  // 2. If confirmed, call the notifier to perform the deletion.
  if (confirmed ?? false) {
    await notifier.deleteItem(path, isFolder: isFolder);
  }
}
