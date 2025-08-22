import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/features/document_prep/providers/document_providers.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pdf_compression_provider.g.dart';

@immutable
class PdfCompressionState {
  const PdfCompressionState({
    this.pickedPdf,
    this.compressedPdfBytes,
    this.isProcessing = false,
    this.sizeLimitKB = 500,
    this.preserveText = true,
    this.successMessage,
    this.errorMessage,
  });
  final PickedFile? pickedPdf;
  final Uint8List? compressedPdfBytes;
  final bool isProcessing;
  final int sizeLimitKB;
  final bool preserveText;
  final String? successMessage;
  final String? errorMessage;

  PdfCompressionState copyWith({
    PickedFile? pickedPdf,
    ValueGetter<Uint8List?>? compressedPdfBytes,
    bool? isProcessing,
    int? sizeLimitKB,
    bool? preserveText,
    String? successMessage,
    String? errorMessage,
  }) {
    return PdfCompressionState(
      pickedPdf: pickedPdf ?? this.pickedPdf,
      compressedPdfBytes: compressedPdfBytes != null
          ? compressedPdfBytes()
          : this.compressedPdfBytes,
      isProcessing: isProcessing ?? this.isProcessing,
      sizeLimitKB: sizeLimitKB ?? this.sizeLimitKB,
      preserveText: preserveText ?? this.preserveText,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}

@Riverpod(keepAlive: false)
class PdfCompressionViewModel extends _$PdfCompressionViewModel {
  @override
  Future<PdfCompressionState> build(PickedFile? initialFile) async {
    if (initialFile == null) {
      return const PdfCompressionState();
    }
    final initialSizeLimit = (initialFile.bytes.lengthInBytes / 1024 / 2)
        .clamp(50, 5000)
        .toInt();
    return PdfCompressionState(
      pickedPdf: initialFile,
      sizeLimitKB: initialSizeLimit,
    );
  }

  void setSizeLimit(int kb) {
    if (state.value == null) return;
    state = AsyncData(state.value!.copyWith(sizeLimitKB: kb));
  }

  void setPreserveText({required bool value}) {
    if (state.value == null) return;
    state = AsyncData(state.value!.copyWith(preserveText: value));
  }

  Future<bool> compressAndSavePdf({
    required String fileName,
    String? folderPath,
  }) async {
    if (state.value?.pickedPdf == null) return false;

    state = AsyncData(
      state.value!.copyWith(
        isProcessing: true,
      ),
    );
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
        final bytes = await compressedFile.readAsBytes();

        await repo.saveEncryptedDocument(
          fileName: fileName,
          data: bytes,
          folderPath: folderPath,
        );
        await compressedFile.delete();
        success = true;

        return currentState.copyWith(
          isProcessing: false,
          compressedPdfBytes: () => bytes,
          successMessage: 'Successfully compressed and saved to wallet!',
        );
      } else {
        throw Exception('Compression failed: $resultPath');
      }
    });

    if (state.hasError) {
      final previousData = state.asError!.value;
      if (previousData != null) {
        state = AsyncData(previousData.copyWith(isProcessing: false));
      }
    }

    return success;
  }
}
