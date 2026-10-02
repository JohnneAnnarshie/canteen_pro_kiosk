
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:canteen_pro/services/encryption_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr/qr.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

// class OrderData {
//   final String orderId;
//   final String userId;
//   final String userCategoryId;
//   final String userName;
//   final String mealName;
//   final String quantity;
//   final String mealId;
//   final String shift;
//   final String provider;
//   final String servedAt;
//   final String serveDate;
//
//   const OrderData({
//     required this.orderId,
//     required this.userId,
//     required this.userCategoryId,
//     required this.userName,
//     required this.mealName,
//     required this.quantity,
//     required this.mealId,
//     required this.shift,
//     required this.provider,
//     required this.servedAt,
//     required this.serveDate,
//   });
//
//   factory OrderData.fromJson(Map<String, dynamic> json) => OrderData(
//     orderId: json['orderId'] as String,
//     userId: json['userId'] as String,
//     userCategoryId: json['userCategoryId'] as String,
//     userName: json['userName'] as String,
//     mealName: json['mealName'] as String,
//     quantity: json['quantity'] as String,
//     mealId: json['mealId'] as String,
//     shift: json['shift'] as String,
//     provider: json['provider'] as String,
//     servedAt: json['servedAt'] as String,
//     serveDate: json['serveDate'] as String,
//   );
//
//   Map<String, dynamic> toJson() => {
//     'orderId': orderId,
//     'userId': userId,
//     'userCategoryId': userCategoryId,
//     'userName': userName,
//     'mealName': mealName,
//     'quantity': quantity,
//     'mealId': mealId,
//     'shift': shift,
//     'provider': provider,
//     'servedAt': servedAt,
//     'serveDate': serveDate,
//   };
// }

/// Stand-in for `com.persol.canteen.utils.toDateWithTime`.
/// The original wasn't provided, so the format below is a guess -
/// adjust the pattern to match your Kotlin implementation.
extension EpochMillisFormatting on int {
  String toDateWithTime() =>
      DateFormat('dd MMM yyyy, HH:mm').format(DateTime.fromMillisecondsSinceEpoch(this));
}

// Not `const` because serveDate depends on the current time.
// final OrderData sampleOrderData = OrderData(
//   orderId: '5dd45ced-51b9-4f62-9f76-00073c0044b1',
//   userId: '37e35a29-d4af-4980-887d-2e7825f02f5a',
//   userCategoryId: '0895bf7a-0a28-4afe-a855-1e14d81755da',
//   userName: 'Jessica Jackson',
//   mealName: 'Yam Chips & Chicken',
//   quantity: '1',
//   mealId: '58f54e55-70ae-40a5-929f-bbbcd6471258',
//   shift: 'Morning',
//   provider: 'Champion',
//   servedAt: 'Persol Canteen',
//   serveDate: DateTime.now().millisecondsSinceEpoch.toDateWithTime(),
// );


// ---------------------------------------------------------------------------
// QR code generation
// ---------------------------------------------------------------------------

class QrCodeUtil {
  QrCodeUtil._();

  static const String _tag = 'QrCodeUtil';

  // Unused in the original as well; kept for parity.
  static const String customUrlScheme = 'canteenapp';

  /// Returns the QR code as PNG bytes together with the orderId,
  /// mirroring `Pair<Bitmap, String>` from the Kotlin version.
  static Future<(Uint8List, String)> generateQrCode(String orderId) async {
    final encryptedJson = CryptoHelper.encryptString(orderId);

    // QR code settings
    const int qrCodeWidth = 500;
    const int qrCodeHeight = 500;
    const int margin = 1; // quiet zone, in modules (EncodeHintType.MARGIN)

    // Generate the QR code (ErrorCorrectionLevel.H = high)
    final qrCode = QrCode.fromData(
      data: encryptedJson,
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );
    final qrImage = QrImage(qrCode);
    final moduleCount = qrImage.moduleCount;

    // Same scaling logic as ZXing's QRCodeWriter.renderResult: integer-sized
    // modules, centred in the requested output size.
    final totalModules = moduleCount + margin * 2;
    final multiple = math.min(
      qrCodeWidth ~/ totalModules,
      qrCodeHeight ~/ totalModules,
    );
    final leftPadding = (qrCodeWidth - moduleCount * multiple) ~/ 2;
    final topPadding = (qrCodeHeight - moduleCount * multiple) ~/ 2;

    // Draw onto a canvas: white background, black modules.
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      ui.Rect.fromLTWH(0, 0, qrCodeWidth.toDouble(), qrCodeHeight.toDouble()),
    );

    final white = ui.Paint()..color = const ui.Color(0xFFFFFFFF);
    final black = ui.Paint()
      ..color = const ui.Color(0xFF000000)
      ..isAntiAlias = false;

    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, qrCodeWidth.toDouble(), qrCodeHeight.toDouble()),
      white,
    );

    for (var row = 0; row < moduleCount; row++) {
      for (var col = 0; col < moduleCount; col++) {
        if (qrImage.isDark(row, col)) {
          canvas.drawRect(
            ui.Rect.fromLTWH(
              (leftPadding + col * multiple).toDouble(),
              (topPadding + row * multiple).toDouble(),
              multiple.toDouble(),
              multiple.toDouble(),
            ),
            black,
          );
        }
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(qrCodeWidth, qrCodeHeight);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();

    if (byteData == null) {
      throw StateError('Failed to encode QR code image');
    }

    debugPrint('$_tag: $encryptedJson');
    return (byteData.buffer.asUint8List(), orderId);
  }

  /// Equivalent of `bitmapToImageFile`: writes the image bytes to the app's
  /// temp (cache) directory and returns the File.
  ///
  /// Note: `dart:ui` can only encode PNG, so this saves PNG by default. If you
  /// need JPEG with a quality setting, decode/re-encode with the `image`
  /// package (`img.encodeJpg(decoded, quality: 95)`).
  static Future<File> bitmapToImageFile(
      Uint8List imageBytes, {
        String? fileName,
      }) async {
    final cacheDir = await getTemporaryDirectory();
    final name = fileName ?? 'image_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${cacheDir.path}/$name');
    await file.writeAsBytes(imageBytes, flush: true);
    return file;
  }
}