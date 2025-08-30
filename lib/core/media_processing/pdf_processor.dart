import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sync_pdf;

/// Provides an instance of [PdfProcessor] for dependency injection.
final pdfProcessorProvider = Provider<PdfProcessor>((ref) {
  return PdfProcessor();
});

/// A payload object for the [_pdfToImageIsolate].
class _PdfToImageRequest {
  _PdfToImageRequest(
    this.pdfBytes,
    this.sendPort,
    this.rootIsolateToken,
    this.password,
    this.tempPath,
  );

  /// The byte data of the PDF file.
  final Uint8List pdfBytes;

  /// The port to send the results back to the main isolate.
  final SendPort sendPort;

  /// The token required to initialize background services in the new isolate.
  final RootIsolateToken rootIsolateToken;

  final String? password;

  final String tempPath;
}

/// A payload object for PDF security operations in isolates.
class _PdfSecurityPayload {
  _PdfSecurityPayload(this.pdfBytes, {this.oldPassword, this.newPassword});

  /// The byte data of the PDF file.
  final Uint8List pdfBytes;

  /// The current password of the PDF, if any.
  final String? oldPassword;

  /// The new password to apply to the PDF.
  final String? newPassword;
}

/// Isolate entry point to check if a PDF is encrypted.
///
/// This function attempts to open a PDF document.
/// If it succeeds, the PDF is not password-protected.
/// If it throws an exception, it is assumed to be encrypted.
bool _isPdfEncryptedIsolate(Uint8List pdfBytes) {
  sync_pdf.PdfDocument? doc;
  try {
    // Attempt to load the document without a password.
    doc = sync_pdf.PdfDocument(inputBytes: pdfBytes);
    return false; // Success means not encrypted.
  } on Object catch (_) {
    return true; // Failure suggests it's password-protected.
  } finally {
    doc?.dispose();
  }
}

/// Isolate entry point to apply a password to a PDF.
Uint8List _lockPdfIsolate(_PdfSecurityPayload payload) {
  final doc = sync_pdf.PdfDocument(inputBytes: payload.pdfBytes);
  doc.security.userPassword = payload.newPassword ?? '';
  final bytes = doc.saveSync();
  doc.dispose();
  return Uint8List.fromList(bytes);
}

/// Isolate entry point to remove the password from a PDF.
Uint8List _unlockPdfIsolate(_PdfSecurityPayload payload) {
  final doc = sync_pdf.PdfDocument(
    inputBytes: payload.pdfBytes,
    password: payload.oldPassword,
  );
  // Re-saving the document without setting a
  //new password effectively removes it.
  final bytes = doc.saveSync();
  doc.dispose();
  return Uint8List.fromList(bytes);
}

/// Isolate entry point to change the password of a PDF.
Uint8List _changePasswordIsolate(_PdfSecurityPayload payload) {
  final doc = sync_pdf.PdfDocument(
    inputBytes: payload.pdfBytes,
    password: payload.oldPassword,
  );
  doc.security.userPassword = payload.newPassword ?? '';
  final bytes = doc.saveSync();
  doc.dispose();
  return Uint8List.fromList(bytes);
}

/// Isolate entry point for converting all pages of a PDF to PNG images.
///
/// This function is asynchronous and uses the `pdfrx` package, which requires
/// platform channel communication. Therefore, it needs a [RootIsolateToken] and
/// manual `Isolate.spawn` management instead of the
/// simpler `compute()` function.

Future<void> _pdfToImageIsolate(_PdfToImageRequest req) async {
  pdfrx.Pdfrx.getCacheDirectory = () => req.tempPath;
  BackgroundIsolateBinaryMessenger.ensureInitialized(req.rootIsolateToken);
  try {
    FutureOr<String?> providePassword() => req.password;

    final doc = await pdfrx.PdfDocument.openData(
      req.pdfBytes,
      passwordProvider: providePassword,
    );

    final images = <Uint8List>[];
    for (final page in doc.pages) {
      final pageImage = await page.render(
        width: page.width.toInt(),
        height: page.height.toInt(),
      );

      if (pageImage?.pixels != null) {
        final rgba = pageImage!.pixels;

        // Convert RGBA raw bytes to image
        final image = img.Image.fromBytes(
          width: pageImage.width,
          height: pageImage.height,
          bytes: rgba.buffer,
          order: img.ChannelOrder.rgba,
        );

        // Encode to PNG
        final pngBytes = Uint8List.fromList(img.encodePng(image));

        images.add(pngBytes);
      }
    }

    await doc.dispose();
    req.sendPort.send(images);
  } on Object catch (e) {
    req.sendPort.send(e);
  }
}

/// Isolate entry point for converting a single image into a single-page PDF.
Uint8List _imageToPdfIsolate(Uint8List imageBytes) {
  final pdf = sync_pdf.PdfDocument();
  final page = pdf.pages.add();
  final image = sync_pdf.PdfBitmap(imageBytes);

  page.graphics.drawImage(
    image,
    Rect.fromLTWH(
      0,
      0,
      page.getClientSize().width,
      page.getClientSize().height,
    ),
  );

  final bytes = pdf.saveSync();
  pdf.dispose();
  return Uint8List.fromList(bytes);
}

/// Isolate entry point for converting a list of images into a multi-page PDF.
/// Each image is placed on a new page, centered and scaled to fit.
Uint8List _imagesToPdfIsolate(List<Uint8List> imageBytesList) {
  final pdf = sync_pdf.PdfDocument();
  // Set page margins to zero to maximize image area.
  pdf.pageSettings.margins.all = 0;

  for (final imageBytes in imageBytesList) {
    final page = pdf.pages.add();
    final image = sync_pdf.PdfBitmap(imageBytes);
    final pageSize = page.getClientSize();

    // Calculate aspect ratios to scale the image correctly without distortion.
    final imageAspectRatio = image.width / image.height;
    final pageAspectRatio = pageSize.width / pageSize.height;

    Rect drawRect;
    if (imageAspectRatio > pageAspectRatio) {
      // Image is wider than the page.
      final scaledHeight = pageSize.width / imageAspectRatio;
      drawRect = Rect.fromLTWH(
        0,
        (pageSize.height - scaledHeight) / 2, // Center vertically
        pageSize.width,
        scaledHeight,
      );
    } else {
      // Image is taller than or same aspect ratio as the page.
      final scaledWidth = pageSize.height * imageAspectRatio;
      drawRect = Rect.fromLTWH(
        (pageSize.width - scaledWidth) / 2, // Center horizontally
        0,
        scaledWidth,
        pageSize.height,
      );
    }

    page.graphics.drawImage(image, drawRect);
  }

  final bytes = pdf.saveSync();
  pdf.dispose();
  return Uint8List.fromList(bytes);
}

/// A service class for performing heavy
/// PDF processing operations in background isolates.
class PdfProcessor {
  /// Converts each page of a PDF document into a PNG image.
  ///
  /// This operation runs in a separate isolate to prevent UI jank.
  Future<List<Uint8List>> convertPdfToImages({
    required Uint8List pdfBytes,
    String? password,
  }) async {
    final receivePort = ReceivePort();
    final token = RootIsolateToken.instance;
    if (token == null) {
      throw Exception('RootIsolateToken is null. Cannot spawn isolate.');
    }

    // ADDED: Get the temp path here in the main isolate
    final tempDir = await getTemporaryDirectory();

    await Isolate.spawn(
      _pdfToImageIsolate,
      _PdfToImageRequest(
        pdfBytes,
        receivePort.sendPort,
        token,
        password,
        tempDir.path, // ADDED: Pass the path to the isolate
      ),
    );

    final result = await receivePort.first;

    if (result is List<Uint8List>) return result;
    if (result is Error) throw result;
    if (result is Exception) throw result;
    throw Exception('Unknown error from PDF isolate: $result');
  }

  /// Converts a single image into a single-page PDF.
  Future<Uint8List> convertImageToPdf({required Uint8List imageBytes}) async {
    return compute(_imageToPdfIsolate, imageBytes);
  }

  /// Converts a list of images into a multi-page PDF.
  /// Each image is placed on its own page.
  Future<Uint8List> convertImagesToPdf({
    required List<Uint8List> imageBytesList,
  }) async {
    return compute(_imagesToPdfIsolate, imageBytesList);
  }

  /// Checks if a PDF document is password-protected.
  Future<bool> isPdfEncrypted({required Uint8List pdfBytes}) async {
    return compute(_isPdfEncryptedIsolate, pdfBytes);
  }

  /// Applies password protection to a PDF document.
  Future<Uint8List> lockPdf({
    required Uint8List pdfBytes,
    required String password,
  }) async {
    return compute(
      _lockPdfIsolate,
      _PdfSecurityPayload(pdfBytes, newPassword: password),
    );
  }

  /// Removes password protection from a PDF document.
  Future<Uint8List> unlockPdf({
    required Uint8List pdfBytes,
    required String password,
  }) async {
    return compute(
      _unlockPdfIsolate,
      _PdfSecurityPayload(pdfBytes, oldPassword: password),
    );
  }

  /// Changes the password of a password-protected PDF document.
  Future<Uint8List> changePdfPassword({
    required Uint8List pdfBytes,
    required String oldPassword,
    required String newPassword,
  }) async {
    return compute(
      _changePasswordIsolate,
      _PdfSecurityPayload(
        pdfBytes,
        oldPassword: oldPassword,
        newPassword: newPassword,
      ),
    );
  }
}
