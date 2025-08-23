import 'dart:io';

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
  const HomeState({this.currentFolderPath});

  /// The relative path of the folder the user is currently viewing.
  /// A `null` value represents the root of the wallet.
  final String? currentFolderPath;

  /// Creates a copy of the state with updated values.
  HomeState copyWith({String? currentFolderPath}) {
    // This allows setting the path back to null.
    return HomeState(
      currentFolderPath: currentFolderPath,
    );
  }

  @override
  List<Object?> get props => [currentFolderPath];
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
    state = state.copyWith(currentFolderPath: newPath);
  }

  /// Navigates to a specific, absolute path within the wallet.
  void navigateToPath(String? path) {
    state = state.copyWith(currentFolderPath: path);
  }

  /// Navigates one level up in the folder hierarchy.
  void navigateUp() {
    if (state.currentFolderPath != null) {
      final parent = p.dirname(state.currentFolderPath!);
      // p.dirname of a root folder returns '.', so we
      // check for that to navigate to null (root).
      state = state.copyWith(
        currentFolderPath: (parent == '.') ? null : parent,
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
    } on Exception catch (e) {
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
    } on Exception catch (e) {
      return 'Share failed: $e'; // Failure
    }
  }
}
