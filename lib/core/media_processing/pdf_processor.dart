import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sync_pdf;

class _PdfToImageRequest {
  _PdfToImageRequest(this.pdfBytes, this.sendPort, this.rootIsolateToken);
  final Uint8List pdfBytes;
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;
}

class _PdfSecurityPayload {
  _PdfSecurityPayload(this.pdfBytes, {this.oldPassword, this.newPassword});
  final Uint8List pdfBytes;
  final String? oldPassword;
  final String? newPassword;
}

bool _isPdfEncryptedIsolate(Uint8List pdfBytes) {
  sync_pdf.PdfDocument? doc;
  try {
    doc = sync_pdf.PdfDocument(inputBytes: pdfBytes);
    return false;
  } on Exception catch (_) {
    return true;
  } finally {
    doc?.dispose();
  }
}

Uint8List _lockPdfIsolate(_PdfSecurityPayload payload) {
  final doc = sync_pdf.PdfDocument(inputBytes: payload.pdfBytes);
  doc.security.userPassword = payload.newPassword ?? '';
  final bytes = doc.saveSync();
  doc.dispose();
  return Uint8List.fromList(bytes);
}

Uint8List _unlockPdfIsolate(_PdfSecurityPayload payload) {
  final doc = sync_pdf.PdfDocument(
    inputBytes: payload.pdfBytes,
    password: payload.oldPassword,
  );
  final bytes = doc.saveSync();
  doc.dispose();
  return Uint8List.fromList(bytes);
}

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

Future<void> _pdfToImageIsolate(_PdfToImageRequest req) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(req.rootIsolateToken);

  final images = <Uint8List>[];
  try {
    final doc = await PdfDocument.openData(req.pdfBytes);
    for (var i = 1; i <= doc.pagesCount; i++) {
      final page = await doc.getPage(i);
      final pageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.png,
      );
      if (pageImage?.bytes != null) {
        images.add(pageImage!.bytes);
      }
      await page.close();
    }
    await doc.close();
    req.sendPort.send(images);
  } on Exception catch (_) {
    req.sendPort.send(<Uint8List>[]);
  }
}

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

Uint8List _imagesToPdfIsolate(List<Uint8List> imageBytesList) {
  final pdf = sync_pdf.PdfDocument();
  pdf.pageSettings.margins.all = 0;

  for (final imageBytes in imageBytesList) {
    final page = pdf.pages.add();
    final image = sync_pdf.PdfBitmap(imageBytes);
    final pageSize = page.getClientSize();

    final imageAspectRatio = image.width / image.height;
    final pageAspectRatio = pageSize.width / pageSize.height;

    Rect drawRect;
    if (imageAspectRatio > pageAspectRatio) {
      final scaledHeight = pageSize.width / imageAspectRatio;
      drawRect = Rect.fromLTWH(
        0,
        (pageSize.height - scaledHeight) / 2,
        pageSize.width,
        scaledHeight,
      );
    } else {
      final scaledWidth = pageSize.height * imageAspectRatio;
      drawRect = Rect.fromLTWH(
        (pageSize.width - scaledWidth) / 2,
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

class PdfProcessor {
  Future<List<Uint8List>> convertPdfToImages({
    required Uint8List pdfBytes,
  }) async {
    final receivePort = ReceivePort();
    final token = RootIsolateToken.instance;

    if (token == null) {
      throw Exception('RootIsolateToken is null. Cannot spawn isolate.');
    }

    await Isolate.spawn(
      _pdfToImageIsolate,
      _PdfToImageRequest(pdfBytes, receivePort.sendPort, token),
    );

    final result = await receivePort.first;
    if (result is List<Uint8List>) {
      return result;
    }
    return [];
  }

  Future<Uint8List> convertImageToPdf({required Uint8List imageBytes}) async {
    return compute(_imageToPdfIsolate, imageBytes);
  }

  Future<Uint8List> convertImagesToPdf({
    required List<Uint8List> imageBytesList,
  }) async {
    return compute(_imagesToPdfIsolate, imageBytesList);
  }

  Future<bool> isPdfEncrypted({required Uint8List pdfBytes}) async {
    return compute(_isPdfEncryptedIsolate, pdfBytes);
  }

  Future<Uint8List> lockPdf({
    required Uint8List pdfBytes,
    required String password,
  }) async {
    return compute(
      _lockPdfIsolate,
      _PdfSecurityPayload(pdfBytes, newPassword: password),
    );
  }

  Future<Uint8List> unlockPdf({
    required Uint8List pdfBytes,
    required String password,
  }) async {
    return compute(
      _unlockPdfIsolate,
      _PdfSecurityPayload(pdfBytes, oldPassword: password),
    );
  }

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
