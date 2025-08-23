import 'dart:async';
import 'dart:io';

import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pdf_compression_provider.g.dart';

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
///
/// Manages the state and business logic for compressing a PDF to a target
/// size using a high-performance native implementation.
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
  /// This method orchestrates the entire flow:
  /// 1. Calls the native compression service.
  /// 2. Reads the temporary compressed file.
  /// 3. Saves the compressed data to the wallet via the repository.
  /// 4. Deletes the temporary file.
  ///
  /// Returns `true` on success and `false` on failure.
  Future<bool> compressAndSavePdf({
    required String fileName,
    String? folderPath,
  }) async {
    if (state.value?.pickedPdf?.path == null) return false;

    state = const AsyncLoading<PdfCompressionState>().copyWithPrevious(state);
    var success = false;

    state = await AsyncValue.guard(() async {
      final currentState = state.value!;
      final repo = await ref.read(documentRepositoryProvider.future);

      final resultPath = await repo.compressPdfWithNative(
        filePath: currentState.pickedPdf!.path!,
        sizeLimit: currentState.sizeLimitKB,
        preserveText: currentState.preserveText,
      );

      if (resultPath == null) {
        throw Exception('Compression was cancelled or failed unexpectedly.');
      }

      final compressedFile = File(resultPath);
      if (await compressedFile.exists()) {
        try {
          final bytes = await compressedFile.readAsBytes();

          await repo.saveEncryptedDocument(
            fileName: fileName,
            data: bytes,
            folderPath: folderPath,
          );
          success = true;

          return currentState.copyWith(
            compressedPdfBytes: () => bytes,
          );
        } finally {
          // Ensure the temporary file is always deleted.
          await compressedFile.delete();
        }
      } else {
        throw Exception('Native compression failed to produce an output file.');
      }
    });

    // If an error occurred, reset to the previous valid data state.
    if (state.hasError) {
      state = AsyncData(state.asError!.value!);
    }

    return success;
  }
}
