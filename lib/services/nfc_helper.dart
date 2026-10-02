import 'dart:convert';

import 'package:canteen_pro/utils/cancel_token.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class NFCHelper {
  NFCHelper._internal();
  static final NFCHelper _instance = NFCHelper._internal();
  factory NFCHelper() => _instance;

  /// Checks if NFC is available on the device.
  static Future<bool> get isNFCSupported async {
    return await FlutterNfcKit.nfcAvailability == NFCAvailability.available;
  }

  CancelToken? _cancelToken;
  /// Starts an NFC session to scan for tags.
  ///
  /// Returns the tag ID as a hexadecimal string if a tag is found,
  /// or null if no tag is found or an error occurs.
   Future<String?> scanNFCTag() async {
    try {
      _cancelToken = CancelToken();
      // Check if NFC is supported
      if (!await isNFCSupported) {
        _cancelToken = null;
        debugPrint('NFC is not supported on this device.');
        return null;
      }
      // Start the NFC session
      _cancelToken?.throwIfCancelled();
    var tag = await FlutterNfcKit.poll(timeout: const Duration(seconds: 5),);
      debugPrint(jsonEncode(tag));
      if (tag.type == NFCTagType.iso7816) {
        var result = await FlutterNfcKit.transceive("00B0950000", timeout: const Duration(seconds: 5)); // timeout is still Android-only, persist until next change
        debugPrint(result);
      }
      if (tag.ndefAvailable!) {
        /// decoded NDEF records (see [ndef.NDEFRecord] for details)
        /// `UriRecord: id=(empty) typeNameFormat=TypeNameFormat.nfcWellKnown type=U uri=https://github.com/nfcim/ndef`
        for (var record in await FlutterNfcKit.readNDEFRecords(cached: false)) {
          debugPrint(record.toString());
        }
        /// raw NDEF records (data in hex string)
        /// `{identifier: "", payload: "00010203", type: "0001", typeNameFormat: "nfcWellKnown"}`
        for (var record in await FlutterNfcKit.readNDEFRawRecords(cached: false)) {
          debugPrint(jsonEncode(record).toString());
        }
      }

      // Check if the tag has an identifier
      // if (tag.id == null) {
      //   debugPrint('Tag does not have an identifier.');
      //   return null;
      // }

      // Convert the identifier to a hexadecimal string
      final String tagId = tag.id;

      // Print the tag ID
      debugPrint('Scanned NFC Tag ID: $tagId');

      return tagId;
    } catch (e) {
      debugPrint('Error scanning NFC tag: $e');
      return null;
    } finally {
      // Stop the NFC session
      await FlutterNfcKit.finish();
    }
  }

  void cancelScan() {
     _cancelToken?.cancel();
  }

  /// Converts a list of bytes to a hexadecimal string.
  static String bytesToHex(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}