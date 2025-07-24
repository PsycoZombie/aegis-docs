import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../document_prep/providers/document_providers.dart';

part 'wallet_provider.g.dart';

@riverpod
class Wallet extends _$Wallet {
  @override
  Future<List<File>> build() async {
    final repository = ref.read(documentRepositoryProvider);
    return repository.listEncryptedFiles();
  }

  Future<void> deleteDocument(String fileName) async {
    final repository = ref.read(documentRepositoryProvider);

    state = const AsyncValue.loading();

    await repository.deleteEncryptedDocument(fileName);

    state = await AsyncValue.guard(() => repository.listEncryptedFiles());
  }

  Future<void> refresh() async {
    final repository = ref.read(documentRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.listEncryptedFiles());
  }
}

@riverpod
Future<Uint8List?> documentDetail(Ref ref, {required String fileName}) async {
  final repository = ref.read(documentRepositoryProvider);
  return repository.loadDecryptedDocument(fileName);
}
