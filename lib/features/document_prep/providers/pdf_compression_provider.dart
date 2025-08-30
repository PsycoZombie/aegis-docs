import 'dart:io';

import 'package:aegis_docs/core/services/native_pdf_compression_service.dart';
import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'pdf_compression_provider.g.dart';

/// A class to hold the structured result of a PDF compression operation.
class PdfCompressionResult {
  /// Creates an instance of the compression result.
  const PdfCompressionResult({required this.status, this.message});

  /// The status indicating the outcome of the operation.
  final NativeCompressionStatus status;

  /// An optional message, which could be an error detail or other info.
  final String? message;
}

/// Represents the state for the PDF compression feature.
@immutable
class PdfCompressionState extends Equatable {
  /// Creates an instance of the PDF compression state.
  const PdfCompressionState({
    this.pickedPdf,
    this.compressedPdfBytes,
    this.sizeLimitKB = 500,
    this.preserveText = true,
  });

  /// The original PDF file selected by the user.
  final PickedFileModel? pickedPdf;

  /// The resulting compressed PDF data.
  final Uint8List? compressedPdfBytes;

  /// The user-defined target size limit in kilobytes.
  final int sizeLimitKB;

  /// A flag to determine if the native compressor
  /// should preserve selectable text.
  final bool preserveText;

  /// Creates a copy of the state with updated values.
  PdfCompressionState copyWith({
    PickedFileModel? pickedPdf,
    ValueGetter<Uint8List?>? compressedPdfBytes,
    int? sizeLimitKB,
    bool? preserveText,
  }) {
    return PdfCompressionState(
      pickedPdf: pickedPdf ?? this.pickedPdf,
      compressedPdfBytes: compressedPdfBytes != null
          ? compressedPdfBytes()
          : this.compressedPdfBytes,
      sizeLimitKB: sizeLimitKB ?? this.sizeLimitKB,
      preserveText: preserveText ?? this.preserveText,
    );
  }

  @override
  List<Object?> get props => [
    pickedPdf,
    compressedPdfBytes,
    sizeLimitKB,
    preserveText,
  ];
}

/// A ViewModel for the native PDF compression feature.
@Riverpod(keepAlive: false)
class PdfCompressionViewModel extends _$PdfCompressionViewModel {
  /// Initializes the state with an optional initial file.
  @override
  Future<PdfCompressionState> build(PickedFileModel? initialFile) async {
    if (initialFile == null || initialFile.bytes == null) {
      return const PdfCompressionState();
    }
    // Set a reasonable initial target size, e.g., 50% of the original size.
    final initialSizeLimit = (initialFile.bytes!.lengthInBytes / 1024 / 2)
        .clamp(50, 5000)
        .toInt();
    return PdfCompressionState(
      pickedPdf: initialFile,
      sizeLimitKB: initialSizeLimit,
    );
  }

  /// Updates the target size limit for the compression.
  void setSizeLimit(int kb) {
    if (state.value == null) return;
    state = AsyncData(state.value!.copyWith(sizeLimitKB: kb));
  }

  /// Updates the "preserve text" option for the compression.
  void setPreserveText({required bool value}) {
    if (state.value == null) return;
    state = AsyncData(state.value!.copyWith(preserveText: value));
  }

  /// Compresses the PDF and saves the result to the secure wallet.
  ///
  /// Returns a [PdfCompressionResult] indicating the outcome of the operation.
  Future<PdfCompressionResult> compressAndSavePdf({
    required String fileName,
    String? folderPath,
    String? password,
  }) async {
    final originalPdf = state.value?.pickedPdf;
    if (originalPdf?.bytes == null || originalPdf?.path == null) {
      return const PdfCompressionResult(
        status: NativeCompressionStatus.errorUnknown,
        message: 'No PDF file was selected.',
      );
    }

    final currentState = state.value!;
    final repo = await ref.read(documentRepositoryProvider.future);

    // This check runs first. If it throws, the UI will catch it.
    final isEncrypted = await repo.isPdfEncrypted(originalPdf!.bytes!);
    if (isEncrypted && password == null) {
      throw const PdfPasswordException('PASSWORD ERROR');
    }

    state = const AsyncLoading<PdfCompressionState>().copyWithPrevious(state);
    File? tempDecryptedFile;
    try {
      var filePathForCompression = originalPdf.path!;
      if (password != null) {
        final decryptedBytes = await repo.unlockPdf(
          originalPdf.bytes!,
          password: password,
        );
        final tempDir = Directory.systemTemp;
        tempDecryptedFile = File(
          '${tempDir.path}/temp_unlocked_${const Uuid().v4()}.pdf',
        );
        await tempDecryptedFile.writeAsBytes(decryptedBytes);
        filePathForCompression = tempDecryptedFile.path;
      }

      final result = await repo.compressPdfWithNative(
        filePath: filePathForCompression,
        sizeLimit: currentState.sizeLimitKB,
        preserveText: currentState.preserveText,
      );

      if (result.status == NativeCompressionStatus.success ||
          result.status == NativeCompressionStatus.successWithFallback) {
        final compressedFile = File(result.data!);
        if (await compressedFile.exists()) {
          try {
            final bytes = await compressedFile.readAsBytes();
            await repo.saveEncryptedDocument(
              fileName: fileName,
              data: bytes,
              folderPath: folderPath,
            );
            state = AsyncData(
              currentState.copyWith(compressedPdfBytes: () => bytes),
            );
            return PdfCompressionResult(status: result.status);
          } finally {
            await compressedFile.delete();
          }
        }
      }
      state = AsyncData(currentState);
      return PdfCompressionResult(status: result.status, message: result.data);
    } on Exception {
      // Catch the specific error for wrong passwords.
      state = AsyncData(currentState);
      return const PdfCompressionResult(
        status: NativeCompressionStatus.errorBadPassword,
        message: 'Incorrect password.',
      );
    } finally {
      if (tempDecryptedFile != null && await tempDecryptedFile.exists()) {
        await tempDecryptedFile.delete();
      }
    }
  }
}
