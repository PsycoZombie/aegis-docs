import 'dart:io';

import 'package:aegis_docs/data/models/wallet_item.dart';
import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
  ///
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

  /// Renames a folder located at [oldPath] to [newName].
  Future<void> renameFolder({
    required String oldPath,
    required String newName,
  }) async {
    final repo = await ref.read(documentRepositoryProvider.future);
    await repo.renameFolderInWallet(oldPath: oldPath, newName: newName);
  }

  /// Renames a file from [oldName] to [newName] within the [folderPath].
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

  /// Deletes a folder and all its contents recursively.
  Future<void> deleteFolder({required String folderPathToDelete}) async {
    final repo = await ref.read(documentRepositoryProvider.future);
    await repo.deleteFolderFromWallet(folderPath: folderPathToDelete);
  }

  /// Deletes a single document.
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

  /// Exports a decrypted document as a byte list.
  Future<Uint8List?> exportDocument({
    required String fileName,
    String? folderPath,
  }) async {
    final repo = await ref.read(documentRepositoryProvider.future);
    final doc = await repo.exportDecryptedDocument(
      fileName: fileName,
      folderPath: folderPath,
    );
    return doc;
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

/// A provider that decrypts document data and saves it to a temporary file.
///
/// This provider is marked as `.autoDispose` to ensure its cache is cleared
/// when the document screen is closed. This prevents errors from trying to
/// access a temporary file that has already been deleted.
final AutoDisposeFutureProviderFamily<
  File,
  ({String fileName, String? folderPath})
>
decryptedDocumentFileProvider =
    // Add the `.autoDispose` modifier here.
    FutureProvider.autoDispose.family<
      File,
      ({String fileName, String? folderPath})
    >(
      (ref, params) async {
        final decryptedData = await ref.watch(
          documentDetailProvider(
            fileName: params.fileName,
            folderPath: params.folderPath,
          ).future,
        );

        if (decryptedData == null) {
          throw Exception('Failed to load or decrypt document data.');
        }

        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_${params.fileName}',
        );

        return tempFile.writeAsBytes(decryptedData);
      },
    );
