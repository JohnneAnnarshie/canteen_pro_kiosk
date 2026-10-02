import 'dart:math' as math;

import 'package:canteen_pro/utils/app_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class OrderData {
  final String userName;
  final String serveDate;

  const OrderData({required this.userName, required this.serveDate});
}

class PrintHelper {
  PrintHelper._();

  static const String _tag = 'PrintHelper';

  /// Equivalent of detectAvailablePrintServices(). Flutter's `printing`
  /// package doesn't list print jobs, so we log platform print capabilities.
  static Future<void> _detectAvailablePrintServices() async {
    try {
      final info = await Printing.info();
      debugPrint(
        '$_tag: Print capabilities -> '
        'canPrint=${info.canPrint}, '
        'directPrint=${info.directPrint}, '
        'dynamicLayout=${info.dynamicLayout}, '
        'canShare=${info.canShare}, '
        'canRaster=${info.canRaster}',
      );
      if (!info.canPrint) {
        debugPrint('$_tag: No print services found.');
      }
    } catch (e) {
      debugPrint('$_tag: Could not query print services: $e');
    }
  }

  /// Equivalent of showPrintPreview(). Opens the system print preview dialog.
  ///
  /// [qrCodeBytes] must be encoded image bytes (PNG/JPEG).
  /// [appName] replaces context.getString(R.string.app_name).
  static Future<void> showPrintPreview({
    required Uint8List qrCodeBytes,
    required OrderData orderData,
    required String appName,
  }) async {
    try {
      await _detectAvailablePrintServices();

      final jobName = '$appName Document';
      final adapter = QrCodePrintAdapter(
        qrCodeBytes: qrCodeBytes,
        orderData: orderData,
      );

      await Printing.layoutPdf(
        name: jobName,
        onLayout: (PdfPageFormat format) => adapter.onWrite(pageFormat: format),
      );
    } catch (e, st) {
      debugPrint('$_tag: Error showing print preview: $e\n$st');
    }
  }
}

class PrintLayoutInfo {
  final String documentName;
  final int pageCount;
  final PdfPageFormat pageFormat;

  const PrintLayoutInfo({
    required this.documentName,
    required this.pageCount,
    required this.pageFormat,
  });
}

class QrCodePrintAdapter {
  final Uint8List qrCodeBytes;
  final OrderData orderData;

  QrCodePrintAdapter({required this.qrCodeBytes, required this.orderData});

  static const String _tag = 'QrCodePrintAdapter';
  static const double _pageMargin = 32;
  static const double _reservedTextHeight = 200;

  /// Equivalent of onLayout().
  PrintLayoutInfo onLayout({PdfPageFormat pageFormat = PdfPageFormat.a4}) {
    return PrintLayoutInfo(
      documentName: 'ORD_${DateTime.now().millisecondsSinceEpoch}.pdf',
      pageCount: 1,
      pageFormat: pageFormat,
    );
  }

  /// Equivalent of onWrite(). Returns the PDF bytes.
  Future<Uint8List> onWrite({
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    try {
      final contentWidth = math.max(0.0, pageFormat.width - _pageMargin * 2);
      final contentHeight = math.max(0.0, pageFormat.height - _pageMargin * 2);
      final qrSize = math.min(
        contentWidth,
        math.max(0.0, contentHeight - _reservedTextHeight),
      );

      final pdf = pw.Document();
      final image = pw.MemoryImage(qrCodeBytes);
      final regular = pw.Font.helvetica();
      final bold = pw.Font.helveticaBold();

      pw.Widget infoGroup(String title, String value) {
        return pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Text(
              title,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: bold, fontSize: 23),
            ),
            pw.SizedBox(height: 4),
            pw.SizedBox(
              width: contentWidth,
              height: 24,
              child: pw.FittedBox(
                fit: pw.BoxFit.scaleDown,
                alignment: pw.Alignment.center,
                child: pw.Text(
                  value,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: regular, fontSize: 18),
                ),
              ),
            ),
          ],
        );
      }

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(_pageMargin),
          build:
              (context) => pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  pw.SizedBox(
                    width: qrSize,
                    height: qrSize,
                    child: pw.Image(image, fit: pw.BoxFit.contain),
                  ),
                  infoGroup('Order For:', orderData.userName),
                  infoGroup('Print Time:', DateTime.now().formattedWithDay),
                  infoGroup(
                    'Available Date:',
                    orderData.serveDate.normalizedDateWithTime,
                  ),
                ],
              ),
        ),
      );

      return await pdf.save();
    } catch (e, st) {
      debugPrint('$_tag: Error writing PDF: $e\n$st');
      rethrow; // equivalent of callback.onWriteFailed(...)
    }
  }
}

// ---------------------------------------------------------------------------
// Usage:
//
// final byteData = await qrImage.toByteData();
// await PrintHelper.showPrintPreview(
//   qrCodeBytes: byteData!.buffer.asUint8List(),
//   orderData: OrderData(userName: 'Jane Doe', serveDate: '2026-09-30 12:30'),
//   appName: 'Canteen',
// );
// ---------------------------------------------------------------------------
