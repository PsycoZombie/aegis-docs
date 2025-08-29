import 'dart:io';

import 'package:aegis_docs/core/services/native_pdf_compression_service.dart';
import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  }) async {
    if (state.value?.pickedPdf?.path == null) {
      return const PdfCompressionResult(
        status: NativeCompressionStatus.errorUnknown,
        message: 'No PDF file was selected.',
      );
    }

    state = const AsyncLoading<PdfCompressionState>().copyWithPrevious(state);
    final currentState = state.value!;

    try {
      final repo = await ref.read(documentRepositoryProvider.future);

      final result = await repo.compressPdfWithNative(
        filePath: currentState.pickedPdf!.path!,
        sizeLimit: currentState.sizeLimitKB,
        preserveText: currentState.preserveText,
      );

      // If the compression was successful, read the file and save it.
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
            // Update the UI state to show the compressed preview.
            state = AsyncData(
              currentState.copyWith(
                compressedPdfBytes: () => bytes,
              ),
            );
            return PdfCompressionResult(status: result.status);
          } finally {
            await compressedFile.delete();
          }
        }
      }
      // If compression failed for any reason, return the result directly.
      state = AsyncData(currentState); // Reset to non-loading state
      return PdfCompressionResult(status: result.status, message: result.data);
    } on Object catch (e) {
      state = AsyncData(currentState); // Reset to non-loading state
      return PdfCompressionResult(
        status: NativeCompressionStatus.errorUnknown,
        message: e.toString(),
      );
    }
  }
}
