import 'dart:io';

import 'package:aegis_docs/core/services/haptics_service.dart';
import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'home_provider.g.dart';

/// Represents the state for the home screen, primarily tracking the current
/// navigation path within the wallet.
@immutable
class HomeState extends Equatable {
  /// Creates an instance of the home state.
  const HomeState({
    this.currentFolderPath,
    this.isSelectionMode = false,
    this.selectedItems = const {},
  });

  /// The relative path of the folder the user is currently viewing.
  /// A `null` value represents the root of the wallet.
  final String? currentFolderPath;

  /// Whether currently long pressed or not.
  final bool isSelectionMode;

  /// Set of selected items.
  final Set<String> selectedItems;

  /// Creates a copy of the state with updated values.
  HomeState copyWith({
    String? currentFolderPath,
    bool? isSelectionMode,
    Set<String>? selectedItems,
  }) {
    // This allows setting the path back to null.
    return HomeState(
      currentFolderPath: currentFolderPath,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedItems: selectedItems ?? this.selectedItems,
    );
  }

  @override
  List<Object?> get props => [
    currentFolderPath,
    isSelectionMode,
    selectedItems,
  ];
}

/// A ViewModel for the home screen.
///
/// Manages the navigation state within the wallet's folder structure and
/// orchestrates user actions like creating, renaming,
/// deleting, and sharing items.
@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() {
    return const HomeState();
  }

  /// Navigates into a subfolder.
  void navigateToFolder(String folderName) {
    final newPath = state.currentFolderPath == null
        ? folderName
        : p.join(state.currentFolderPath!, folderName);
    // When navigating, always exit selection mode.
    state = state.copyWith(
      currentFolderPath: newPath,
      isSelectionMode: false,
      selectedItems: {},
    );
  }

  /// Navigates to a specific, absolute path within the wallet.
  void navigateToPath(String? path) {
    state = state.copyWith(
      currentFolderPath: path,
      isSelectionMode: false,
      selectedItems: {},
    );
  }

  /// Navigates one level up in the folder hierarchy.
  void navigateUp() {
    if (state.currentFolderPath != null) {
      final parent = p.dirname(state.currentFolderPath!);
      state = state.copyWith(
        currentFolderPath: (parent == '.') ? null : parent,
        isSelectionMode: false,
        selectedItems: {},
      );
    }
  }

  /// Creates a new folder in the current directory.
  /// Returns `true` on success, `false` if a folder
  /// with the same name already exists.
  Future<bool> createFolder(String folderName) async {
    final notifier = ref.read(
      walletViewModelProvider(state.currentFolderPath).notifier,
    );
    final success = await notifier.createFolder(
      folderName: folderName,
      parentFolderPath: state.currentFolderPath,
    );
    if (success) {
      ref.invalidate(walletViewModelProvider(state.currentFolderPath));
    }
    return success;
  }

  /// Renames a file or folder.
  Future<void> renameItem(
    String oldPath,
    String newName, {
    required bool isFolder,
  }) async {
    final parentPath = state.currentFolderPath;
    final notifier = ref.read(walletViewModelProvider(parentPath).notifier);

    if (isFolder) {
      // For folders, the `oldPath` from the context menu is the full path.
      await notifier.renameFolder(oldPath: oldPath, newName: newName);
    } else {
      final extension = p.extension(oldPath);
      // For files, the `oldName` is just the basename.
      await notifier.renameFile(
        oldName: p.basename(oldPath),
        newName: '$newName$extension',
        folderPath: state.currentFolderPath,
      );
    }
    ref.invalidate(walletViewModelProvider(parentPath));
  }

  /// Deletes a file or folder.
  Future<void> deleteItem(String path, {required bool isFolder}) async {
    final parentPath = state.currentFolderPath;
    final notifier = ref.read(walletViewModelProvider(parentPath).notifier);

    if (isFolder) {
      await notifier.deleteFolder(folderPathToDelete: path);
    } else {
      await notifier.deleteDocument(
        fileName: p.basename(path),
        folderPath: state.currentFolderPath,
      );
    }
    ref.invalidate(walletViewModelProvider(parentPath));
  }

  /// Exports a decrypted document to the device's public downloads folder.
  /// Returns an error message on failure, or `null` on success.
  Future<String?> exportDocument(String fileName) async {
    try {
      final repo = await ref.read(documentRepositoryProvider.future);
      final decryptedBytes = await repo.exportDecryptedDocument(
        fileName: fileName,
        folderPath: state.currentFolderPath,
      );
      if (decryptedBytes == null) {
        throw Exception('Failed to export the document.');
      }
      return null; // Success
    } on Object catch (e) {
      return 'Export failed: $e'; // Failure
    }
  }

  /// Shares a decrypted document using the native OS share sheet.
  /// Returns an error message on failure, or `null` on success.
  Future<String?> shareDocument(String fileName) async {
    try {
      final repo = await ref.read(documentRepositoryProvider.future);
      final decryptedBytes = await repo.loadDecryptedDocument(
        fileName: fileName,
        folderPath: state.currentFolderPath,
      );
      if (decryptedBytes == null) {
        throw Exception('Failed to load document for sharing.');
      }

      // Write the decrypted data to a temporary file for sharing.
      final tempDir = await getTemporaryDirectory();
      final tempFile = await File(
        '${tempDir.path}/$fileName',
      ).writeAsBytes(decryptedBytes);

      final params = ShareParams(
        text: 'Shared from Aegis Docs',
        files: [XFile(tempFile.path)],
      );
      await SharePlus.instance.share(params);

      // Clean up the temporary file.
      await tempFile.delete();
      return null; // Success
    } on Object catch (e) {
      return 'Share failed: $e'; // Failure
    }
  }

  /// Enables selection mode, starting with the first long-pressed item.
  void enableSelectionMode(String path) {
    ref.read(hapticsProvider).mediumImpact(); // Haptic feedback
    state = state.copyWith(
      isSelectionMode: true,
      currentFolderPath: state.currentFolderPath,
      selectedItems: {path},
    );
  }

  /// Toggles the selection status of an item.
  void toggleItemSelection(String path) {
    ref.read(hapticsProvider).lightImpact();
    final newSelection = Set<String>.from(state.selectedItems);
    if (newSelection.contains(path)) {
      newSelection.remove(path);
    } else {
      newSelection.add(path);
    }
    state = state.copyWith(
      selectedItems: newSelection,
      currentFolderPath: state.currentFolderPath,
      isSelectionMode: newSelection.isNotEmpty,
    );
  }

  /// Clears the entire selection and exits selection mode.
  void clearSelection() {
    state = state.copyWith(
      isSelectionMode: false,
      currentFolderPath: state.currentFolderPath,
      selectedItems: {},
    );
  }

  /// Deletes all currently selected items.
  Future<void> deleteSelectedItems() async {
    final parentPath = state.currentFolderPath;
    final notifier = ref.read(walletViewModelProvider(parentPath).notifier);
    final itemsToDelete = List<String>.from(state.selectedItems);

    for (final path in itemsToDelete) {
      final isFolder = p.extension(path).isEmpty;
      if (isFolder) {
        await notifier.deleteFolder(folderPathToDelete: path);
      } else {
        await notifier.deleteDocument(
          fileName: p.basename(path),
          folderPath: parentPath,
        );
      }
    }
    clearSelection();
    ref.invalidate(walletViewModelProvider(parentPath));
  }

  /// Shares all currently selected files.
  Future<String?> shareSelectedItems() async {
    final filesToShare = state.selectedItems
        .where((path) => p.extension(path).isNotEmpty)
        .toList();

    if (filesToShare.isEmpty) {
      clearSelection();
      return 'No files selected to share.';
    }

    try {
      final repo = await ref.read(documentRepositoryProvider.future);
      final tempDir = await getTemporaryDirectory();
      final tempFiles = <XFile>[];

      for (final filePath in filesToShare) {
        final fileName = p.basename(filePath);
        final folderPath = state.currentFolderPath;
        final decryptedBytes = await repo.loadDecryptedDocument(
          fileName: fileName,
          folderPath: folderPath,
        );
        if (decryptedBytes == null) continue;

        final tempFile = await File(
          '${tempDir.path}/$fileName',
        ).writeAsBytes(decryptedBytes);
        tempFiles.add(XFile(tempFile.path));
      }

      if (tempFiles.isEmpty) throw Exception('Failed to load documents.');

      final params = ShareParams(
        files: tempFiles,
      );

      await SharePlus.instance.share(params);

      for (final xfile in tempFiles) {
        await File(xfile.path).delete();
      }
      clearSelection();
      return null;
    } on Object catch (e) {
      return 'Share failed: $e';
    }
  }
}
