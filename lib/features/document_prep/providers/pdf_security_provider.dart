// file: features/document_prep/providers/pdf_security_provider.dart
import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'document_providers.dart';

part 'pdf_security_provider.g.dart';

@immutable
class PdfSecurityState {
  final PickedFile? pickedPdf;
  final bool? isEncrypted;
  final bool isProcessing;
  final String? successMessage;

  const PdfSecurityState({
    this.pickedPdf,
    this.isEncrypted,
    this.isProcessing = false,
    this.successMessage,
  });

  PdfSecurityState copyWith({
    PickedFile? pickedPdf,
    bool? isEncrypted,
    bool? isProcessing,
    String? successMessage,
  }) {
    return PdfSecurityState(
      pickedPdf: pickedPdf ?? this.pickedPdf,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      isProcessing: isProcessing ?? this.isProcessing,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

@riverpod
class PdfSecurityViewModel extends _$PdfSecurityViewModel {
  @override
  Future<PdfSecurityState> build() async {
    return const PdfSecurityState();
  }

  Future<void> pickPdf() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      final pdfFile = await repo.pickPdf();
      if (pdfFile != null) {
        final isEncrypted = await repo.isPdfEncrypted(pdfFile.bytes);
        return PdfSecurityState(pickedPdf: pdfFile, isEncrypted: isEncrypted);
      }
      return const PdfSecurityState();
    });
  }

  Future<void> lockPdf(String password) async {
    if (state.value?.pickedPdf == null) return;
    state = AsyncData(state.value!.copyWith(isProcessing: true));
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      final newBytes = await repo.lockPdf(
        state.value!.pickedPdf!.bytes,
        password: password,
      );
      await repo.saveEncryptedDocument(
        fileName: state.value!.pickedPdf!.name,
        data: newBytes,
      );
      return state.value!.copyWith(
        isProcessing: false,
        successMessage: 'PDF locked and saved!',
      );
    });
  }

  Future<void> unlockPdf(String password) async {
    if (state.value?.pickedPdf == null) return;
    state = AsyncData(state.value!.copyWith(isProcessing: true));
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      final newBytes = await repo.unlockPdf(
        state.value!.pickedPdf!.bytes,
        password: password,
      );
      await repo.saveEncryptedDocument(
        fileName: state.value!.pickedPdf!.name,
        data: newBytes,
      );
      return state.value!.copyWith(
        isProcessing: false,
        successMessage: 'PDF unlocked and saved!',
      );
    });
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    if (state.value?.pickedPdf == null) return;
    state = AsyncData(state.value!.copyWith(isProcessing: true));
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      final newBytes = await repo.changePdfPassword(
        state.value!.pickedPdf!.bytes,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      await repo.saveEncryptedDocument(
        fileName: state.value!.pickedPdf!.name,
        data: newBytes,
      );
      return state.value!.copyWith(
        isProcessing: false,
        successMessage: 'Password changed and saved!',
      );
    });
  }
}
