import 'dart:io';

import 'package:aegis_docs/features/document_prep/providers/document_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet_provider.g.dart';

@immutable
class WalletState {

  const WalletState({this.folders = const [], this.files = const []});
  final List<Directory> folders;
  final List<File> files;
}

@Riverpod(keepAlive: false)
class WalletViewModel extends _$WalletViewModel {
  @override
  Future<WalletState> build(String? folderPath) async {
    final repository = await ref.read(documentRepositoryProvider.future);
    final contents = await repository.listWalletContents(
      folderPath: folderPath,
    );

    final folders = contents.whereType<Directory>().toList();
    final files = contents.whereType<File>().toList();

    folders.sort((a, b) => a.path.compareTo(b.path));
    files.sort((a, b) => a.path.compareTo(b.path));

    return WalletState(folders: folders, files: files);
  }

  Future<void> deleteDocument({
    required String fileName,
    required String? folderPath,
  }) async {
    final repository = await ref.read(documentRepositoryProvider.future);
    state = const AsyncValue.loading();
    await repository.deleteEncryptedDocument(
      fileName: fileName,
      folderPath: folderPath,
    );
    ref.invalidateSelf();
  }

  Future<List<int>?> exportDocument({
    required String fileName,
    String? folderPath,
  }) async {
    final repository = await ref.read(documentRepositoryProvider.future);
    return repository.exportDecryptedDocument(
      fileName: fileName,
      folderPath: folderPath,
    );
  }

  Future<bool> createFolder({
    required String folderName,
    required String? parentFolderPath,
  }) async {
    if (state.value != null) {
      final folderExists = state.value!.folders.any(
        (dir) => p.basename(dir.path).toLowerCase() == folderName.toLowerCase(),
      );
      if (folderExists) {
        return false;
      }
    }

    final repository = await ref.read(documentRepositoryProvider.future);
    state = const AsyncValue.loading();
    await repository.createFolderInWallet(
      folderName: folderName,
      parentFolderPath: parentFolderPath,
    );
    ref.invalidateSelf();
    return true;
  }

  Future<void> deleteFolder({required String folderPathToDelete}) async {
    final repository = await ref.read(documentRepositoryProvider.future);
    state = const AsyncValue.loading();
    await repository.deleteFolderFromWallet(folderPath: folderPathToDelete);
    ref.invalidateSelf();
  }

  void refresh() {
    ref.invalidateSelf();
  }

  Future<void> renameFile({
    required String oldName,
    required String newName,
    required String? folderPath,
  }) async {
    final repository = await ref.read(documentRepositoryProvider.future);
    await repository.renameFileInWallet(
      oldName: oldName,
      newName: newName,
      folderPath: folderPath,
    );
    ref.invalidateSelf();
  }

  Future<void> renameFolder({
    required String oldPath,
    required String newName,
  }) async {
    final repository = await ref.read(documentRepositoryProvider.future);
    await repository.renameFolderInWallet(oldPath: oldPath, newName: newName);
    ref.invalidateSelf();
  }
}

@riverpod
Future<List<String>> allFolders(Ref ref) async {
  final repository = await ref.read(documentRepositoryProvider.future);
  return repository.listAllFolders();
}

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
