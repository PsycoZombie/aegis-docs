import 'dart:async';

import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pdf_security_provider.g.dart';

/// Represents the state for the PDF security feature.
@immutable
class PdfSecurityState extends Equatable {
  /// Creates an instance of the PDF security state.
  const PdfSecurityState({
    this.pickedPdf,
    this.processedPdfBytes,
    this.isEncrypted,
  });

  /// The original PDF file selected by the user.
  final PickedFileModel? pickedPdf;

  /// The resulting PDF data after a security operation (lock/unlock).
  final Uint8List? processedPdfBytes;

  /// A boolean indicating if the original PDF is password-protected.
  final bool? isEncrypted;

  /// Creates a copy of the state with updated values.
  PdfSecurityState copyWith({
    PickedFileModel? pickedPdf,
    ValueGetter<Uint8List?>? processedPdfBytes,
    bool? isEncrypted,
  }) {
    return PdfSecurityState(
      pickedPdf: pickedPdf ?? this.pickedPdf,
      processedPdfBytes: processedPdfBytes != null
          ? processedPdfBytes()
          : this.processedPdfBytes,
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }

  @override
  List<Object?> get props => [pickedPdf, processedPdfBytes, isEncrypted];
}

/// A ViewModel for the PDF security feature.
///
/// Manages the state and business logic for adding, removing, or changing
/// a PDF's password protection.
@Riverpod(keepAlive: false)
class PdfSecurityViewModel extends _$PdfSecurityViewModel {
  /// Initializes the state by checking if the initial PDF is encrypted.
  @override
  Future<PdfSecurityState> build(PickedFileModel? initialFile) async {
    if (initialFile == null || initialFile.bytes == null) {
      return const PdfSecurityState();
    }
    final repo = await ref.read(documentRepositoryProvider.future);
    final isEncrypted = await repo.isPdfEncrypted(initialFile.bytes!);
    return PdfSecurityState(pickedPdf: initialFile, isEncrypted: isEncrypted);
  }

  /// Applies password protection to the PDF.
  /// Returns `true` on success, `false` on failure.
  Future<bool> lockPdf(String password) async {
    if (state.value?.pickedPdf?.bytes == null) return false;

    state = const AsyncLoading<PdfSecurityState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      final newBytes = await repo.lockPdf(
        state.value!.pickedPdf!.bytes!,
        password: password,
      );
      return state.value!.copyWith(
        processedPdfBytes: () => newBytes,
        isEncrypted: true, // The PDF is now encrypted
      );
    });
    return !state.hasError;
  }

  /// Removes password protection from the PDF.
  /// Returns `true` on success, `false` on failure (e.g., wrong password).
  Future<bool> unlockPdf(String password) async {
    if (state.value?.pickedPdf?.bytes == null) return false;

    state = const AsyncLoading<PdfSecurityState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      final newBytes = await repo.unlockPdf(
        state.value!.pickedPdf!.bytes!,
        password: password,
      );
      return state.value!.copyWith(
        processedPdfBytes: () => newBytes,
        isEncrypted: false, // The PDF is now decrypted
      );
    });
    return !state.hasError;
  }

  /// Changes the password of an encrypted PDF.
  /// Returns `true` on success, `false` on failure.
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (state.value?.pickedPdf?.bytes == null) return false;

    state = const AsyncLoading<PdfSecurityState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      final newBytes = await repo.changePdfPassword(
        state.value!.pickedPdf!.bytes!,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return state.value!.copyWith(
        processedPdfBytes: () => newBytes,
      );
    });
    return !state.hasError;
  }

  /// Saves the processed PDF (with updated security) to the secure wallet.
  Future<void> savePdf({required String fileName, String? folderPath}) async {
    if (state.value?.processedPdfBytes == null) {
      throw Exception('No processed PDF to save.');
    }
    final currentState = state.value!;

    state = const AsyncLoading<PdfSecurityState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(documentRepositoryProvider.future);
      await repo.saveEncryptedDocument(
        fileName: fileName,
        data: currentState.processedPdfBytes!,
        folderPath: folderPath,
      );
      return currentState;
    });
  }
}
