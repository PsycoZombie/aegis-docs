import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sync_pdf;

class _PdfToImageRequest {
  final Uint8List pdfBytes;
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;

  _PdfToImageRequest(this.pdfBytes, this.sendPort, this.rootIsolateToken);
}

void _pdfToImageIsolate(_PdfToImageRequest req) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(req.rootIsolateToken);

  final images = <Uint8List>[];
  try {
    final doc = await PdfDocument.openData(req.pdfBytes);
    for (int i = 1; i <= doc.pagesCount; i++) {
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
  } catch (e) {
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
      final double scaledHeight = pageSize.width / imageAspectRatio;
      drawRect = Rect.fromLTWH(
        0,
        (pageSize.height - scaledHeight) / 2,
        pageSize.width,
        scaledHeight,
      );
    } else {
      final double scaledWidth = pageSize.height * imageAspectRatio;
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
      throw Exception("RootIsolateToken is null. Cannot spawn isolate.");
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
    return await compute(_imageToPdfIsolate, imageBytes);
  }

  Future<Uint8List> convertImagesToPdf({
    required List<Uint8List> imageBytesList,
  }) async {
    return await compute(_imagesToPdfIsolate, imageBytesList);
  }
}
