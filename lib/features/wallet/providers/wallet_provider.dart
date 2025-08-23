import 'dart:io';

import 'package:aegis_docs/data/models/wallet_item.dart';
import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet_provider.g.dart';

/// Represents the state for the wallet view,
/// containing lists of folders and files.
@immutable
class WalletState extends Equatable {
  /// Creates an instance of the wallet state.
  const WalletState({
    this.folders = const [],
    this.files = const [],
  });

  /// The list of folders in the current directory.
  final List<FolderModel> folders;

  /// The list of documents in the current directory.
  final List<DocumentModel> files;

  @override
  List<Object?> get props => [folders, files];
}

/// A ViewModel that provides the contents (folders and files) for a specific
/// directory within the secure wallet.
@riverpod
class WalletViewModel extends _$WalletViewModel {
  /// Initializes the state by fetching the
  /// contents of the specified folder path.
  @override
  Future<WalletState> build(String? folderPath) async {
    final repo = await ref.watch(documentRepositoryProvider.future);
    final contents = await repo.listWalletContents(folderPath: folderPath);

    final folders = <FolderModel>[];
    final files = <DocumentModel>[];

    for (final item in contents) {
      if (item is Directory) {
        folders.add(FolderModel(name: p.basename(item.path), path: item.path));
      } else if (item is File) {
        files.add(DocumentModel(name: p.basename(item.path), path: item.path));
      }
    }

    // Sort alphabetically for a consistent order.
    folders.sort((a, b) => a.name.compareTo(b.name));
    files.sort((a, b) => a.name.compareTo(b.name));

    return WalletState(folders: folders, files: files);
  }

  /// Creates a new folder in the current directory.
  /// Returns `true` on success, `false` if a
  /// folder with the same name already exists.
  Future<bool> createFolder({
    required String folderName,
    String? parentFolderPath,
  }) async {
    if (state.value != null) {
      final folderExists = state.value!.folders.any(
        (folder) => folder.name.toLowerCase() == folderName.toLowerCase(),
      );
      if (folderExists) return false;
    }

    final repo = await ref.read(documentRepositoryProvider.future);
    await repo.createFolderInWallet(
      folderName: folderName,
      parentFolderPath: parentFolderPath,
    );
    return true;
  }

  /// Renames a folder.
  Future<void> renameFolder({
    required String oldPath,
    required String newName,
  }) async {
    final repo = await ref.read(documentRepositoryProvider.future);
    await repo.renameFolderInWallet(oldPath: oldPath, newName: newName);
  }

  /// Renames a file.
  Future<void> renameFile({
    required String oldName,
    required String newName,
    String? folderPath,
  }) async {
    final repo = await ref.read(documentRepositoryProvider.future);
    await repo.renameFileInWallet(
      oldName: oldName,
      newName: newName,
      folderPath: folderPath,
    );
  }

  /// Deletes a folder.
  Future<void> deleteFolder({required String folderPathToDelete}) async {
    final repo = await ref.read(documentRepositoryProvider.future);
    await repo.deleteFolderFromWallet(folderPath: folderPathToDelete);
  }

  /// Deletes a document.
  Future<void> deleteDocument({
    required String fileName,
    String? folderPath,
  }) async {
    final repo = await ref.read(documentRepositoryProvider.future);
    await repo.deleteEncryptedDocument(
      fileName: fileName,
      folderPath: folderPath,
    );
  }

  /// Exports a decrypted document.
  Future<Uint8List?> exportDocument({
    required String fileName,
    String? folderPath,
  }) async {
    final repo = await ref.read(documentRepositoryProvider.future);
    final doc = await repo.exportDecryptedDocument(
      fileName: fileName,
      folderPath: folderPath,
    );
    return Uint8List.fromList(doc!);
  }
}

/// A provider that fetches a list of all
/// folder paths in the wallet recursively.
///
/// This is useful for UI elements like a "move to folder" dialog.
@riverpod
Future<List<String>> allFolders(Ref ref) async {
  final repository = await ref.read(documentRepositoryProvider.future);
  return repository.listAllFolders();
}

/// A provider that fetches and decrypts the content of a single document.
///
/// This is used by the document detail screen to display the file.
@riverpod
Future<Uint8List?> documentDetail(
  Ref ref, {
  required String fileName,
  required String? folderPath,
}) async {
  final repository = await ref.read(documentRepositoryProvider.future);
  return repository.loadDecryptedDocument(
    fileName: fileName,
    folderPath: folderPath,
  );
}
