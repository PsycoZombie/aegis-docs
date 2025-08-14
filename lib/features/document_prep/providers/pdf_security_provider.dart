// file: features/document_prep/providers/pdf_security_provider.dart

import 'dart:async';

import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'document_providers.dart';

part 'pdf_security_provider.g.dart';

@immutable
class PdfSecurityState {
  final PickedFile? pickedPdf;
  final Uint8List? processedPdfBytes;
  final bool? isEncrypted;
  final bool isProcessing;
  // THE FIX: Add the missing successMessage and errorMessage fields.
  final String? successMessage;
  final String? errorMessage;

  const PdfSecurityState({
    this.pickedPdf,
    this.processedPdfBytes,
    this.isEncrypted,
    this.isProcessing = false,
    this.successMessage,
    this.errorMessage,
  });

  PdfSecurityState copyWith({
    PickedFile? pickedPdf,
    ValueGetter<Uint8List?>? processedPdfBytes,
    bool? isEncrypted,
    bool? isProcessing,
    String? successMessage,
    String? errorMessage,
  }) {
    return PdfSecurityState(
      pickedPdf: pickedPdf ?? this.pickedPdf,
      processedPdfBytes: processedPdfBytes != null
          ? processedPdfBytes()
          : this.processedPdfBytes,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      isProcessing: isProcessing ?? this.isProcessing,
      // Use null-aware assignment to allow clearing the messages.
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}

@Riverpod(keepAlive: false)
class PdfSecurityViewModel extends _$PdfSecurityViewModel {
  @override
  Future<PdfSecurityState> build(PickedFile? initialFile) async {
    if (initialFile == null) {
      return const PdfSecurityState();
    }
    final repo = await ref.read(documentRepositoryProvider.future);
    final isEncrypted = await repo.isPdfEncrypted(initialFile.bytes);
    return PdfSecurityState(pickedPdf: initialFile, isEncrypted: isEncrypted);
  }

  Future<bool> lockPdf(String password) async {
    if (state.value?.pickedPdf == null) return false;
    state = AsyncData(
      state.value!.copyWith(
        isProcessing: true,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      final repo = await ref.read(documentRepositoryProvider.future);
      final newBytes = await repo.lockPdf(
        state.value!.pickedPdf!.bytes,
        password: password,
      );
      state = AsyncData(
        state.value!.copyWith(
          isProcessing: false,
          processedPdfBytes: () => newBytes,
        ),
      );
      return true;
    } catch (e) {
      state = AsyncData(
        state.value!.copyWith(
          isProcessing: false,
          errorMessage: 'Failed to lock PDF.',
        ),
      );
      return false;
    }
  }

  Future<bool> unlockPdf(String password) async {
    if (state.value?.pickedPdf == null) return false;
    state = AsyncData(
      state.value!.copyWith(
        isProcessing: true,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      final repo = await ref.read(documentRepositoryProvider.future);
      final newBytes = await repo.unlockPdf(
        state.value!.pickedPdf!.bytes,
        password: password,
      );
      state = AsyncData(
        state.value!.copyWith(
          isProcessing: false,
          processedPdfBytes: () => newBytes,
        ),
      );
      return true;
    } catch (e) {
      debugPrint("Unlock PDF failed: $e");
      state = AsyncData(
        state.value!.copyWith(
          isProcessing: false,
          errorMessage: 'Invalid password. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (state.value?.pickedPdf == null) return false;
    state = AsyncData(
      state.value!.copyWith(
        isProcessing: true,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      final repo = await ref.read(documentRepositoryProvider.future);
      final newBytes = await repo.changePdfPassword(
        state.value!.pickedPdf!.bytes,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      state = AsyncData(
        state.value!.copyWith(
          isProcessing: false,
          processedPdfBytes: () => newBytes,
        ),
      );
      return true;
    } catch (e) {
      debugPrint("Change Password failed: $e");
      state = AsyncData(
        state.value!.copyWith(
          isProcessing: false,
          errorMessage: 'Invalid current password. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<void> savePdf({required String fileName, String? folderPath}) async {
    if (state.value?.processedPdfBytes == null) {
      throw Exception("No processed PDF to save.");
    }
    final currentState = state.value!;
    state = AsyncData(currentState.copyWith(isProcessing: true));
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.saveEncryptedDocument(
        fileName: fileName,
        data: currentState.processedPdfBytes!,
        folderPath: folderPath,
      );
      // THE FIX: Set the success message here, after a successful save.
      return currentState.copyWith(
        isProcessing: false,
        successMessage: 'PDF security updated and saved!',
      );
    });
  }
}
