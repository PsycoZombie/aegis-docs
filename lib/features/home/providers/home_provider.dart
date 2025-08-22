// file: features/home/providers/home_provider.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/rename_dialog.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'home_provider.g.dart';

@immutable
class HomeState {
  const HomeState({this.currentFolderPath, this.infoMessage});
  final String? currentFolderPath;
  // NEW: A field to hold messages for the SnackBar
  final String? infoMessage;

  HomeState copyWith({String? currentFolderPath, String? infoMessage}) {
    return HomeState(
      currentFolderPath: currentFolderPath,
      infoMessage: infoMessage,
    );
  }
}

@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() {
    return const HomeState();
  }

  // --- Navigation Logic ---

  void navigateToFolder(String folderName) {
    final newPath = state.currentFolderPath == null
        ? folderName
        : p.join(state.currentFolderPath!, folderName);
    state = state.copyWith(currentFolderPath: newPath);
  }

  void navigateToPath(String? path) {
    state = state.copyWith(currentFolderPath: path);
  }

  void navigateUp() {
    if (state.currentFolderPath != null) {
      final parent = p.dirname(state.currentFolderPath!);
      state = state.copyWith(
        currentFolderPath: (parent == '.') ? null : parent,
      );
    }
  }

  // --- Business Logic (now includes showing dialogs) ---

  Future<void> createFolder(BuildContext context) async {
    final folderName = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Create New Folder'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Folder Name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (folderName != null && folderName.isNotEmpty) {
      final notifier = ref.read(
        walletViewModelProvider(state.currentFolderPath).notifier,
      );
      final success = await notifier.createFolder(
        folderName: folderName,
        parentFolderPath: state.currentFolderPath,
      );
      if (!success) {
        state = state.copyWith(
          infoMessage: 'A folder named "$folderName" already exists.',
        );
      }
    }
  }

  Future<void> renameItem(
    BuildContext context,
    String path, {
    required bool isFolder,
  }) async {
    final currentName = isFolder
        ? p.basename(path)
        : p.basenameWithoutExtension(path);
    final newName = await showRenameDialog(
      context,
      currentName: currentName,
      title: isFolder ? 'Rename Folder' : 'Rename File',
    );

    if (newName != null && newName.isNotEmpty && newName != currentName) {
      final parentPath = isFolder
          ? ((path == p.basename(path)) ? null : p.dirname(path))
          : state.currentFolderPath;
      final notifier = ref.read(walletViewModelProvider(parentPath).notifier);
      if (isFolder) {
        await notifier.renameFolder(oldPath: path, newName: newName);
      } else {
        final extension = p.extension(path);
        await notifier.renameFile(
          oldName: path,
          newName: '$newName$extension',
          folderPath: state.currentFolderPath,
        );
      }
    }
  }

  Future<void> deleteItem(
    BuildContext context,
    String path, {
    required bool isFolder,
  }) async {
    final name = p.basename(path);
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

    if (confirmed ?? false) {
      final parentPath = isFolder
          ? ((path == p.basename(path)) ? null : p.dirname(path))
          : state.currentFolderPath;
      final notifier = ref.read(walletViewModelProvider(parentPath).notifier);
      if (isFolder) {
        await notifier.deleteFolder(folderPathToDelete: path);
      } else {
        await notifier.deleteDocument(
          fileName: name,
          folderPath: state.currentFolderPath,
        );
      }
    }
  }

  Future<void> exportDocument(String fileName) async {
    try {
      final notifier = ref.read(
        walletViewModelProvider(state.currentFolderPath).notifier,
      );
      final decryptedBytes = await notifier.exportDocument(
        fileName: fileName,
        folderPath: state.currentFolderPath,
      );
      if (decryptedBytes == null) throw Exception('Failed to load document.');
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: Uint8List.fromList(decryptedBytes),
      );
      state = state.copyWith(infoMessage: 'File saved successfully!');
    } on Exception catch (e) {
      state = state.copyWith(infoMessage: 'Export failed: $e');
    }
  }

  Future<void> shareDocument(String fileName) async {
    try {
      final notifier = ref.read(
        walletViewModelProvider(state.currentFolderPath).notifier,
      );
      final decryptedBytes = await notifier.exportDocument(
        fileName: fileName,
        folderPath: state.currentFolderPath,
      );
      if (decryptedBytes == null) {
        throw Exception('Failed to load document for sharing.');
      }

      final tempDir = await getTemporaryDirectory();
      final tempFile = await File(
        '${tempDir.path}/$fileName',
      ).writeAsBytes(decryptedBytes);

      final params = ShareParams(
        text: 'Shared from Aegis Docs',
        files: [XFile(tempFile.path)],
      );
      await SharePlus.instance.share(params);

      await tempFile.delete();
    } on Exception catch (e) {
      state = state.copyWith(infoMessage: 'Share failed: $e');
    }
  }
}
