import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:encrypt/encrypt.dart' as enc;

/// Dart port of the Kotlin EncryptionHelper.
///
/// AES-128 / CBC / PKCS7 (same as Java's "PKCS5Padding" for AES),
/// with a fixed key derived from SHA-256 and a fixed IV, so the output is
/// byte-for-byte compatible with the Android implementation.
class CryptoHelper {
  CryptoHelper._();

  // Raw string: `$` must not be interpolated in Dart.
  static final enc.IV _iv = enc.IV(
    Uint8List.fromList(utf8.encode(r'xG7p!m2@rF9#qL5$')), // 16 bytes
  );

  static final enc.Key _key = () {
    final digest =
        crypto.sha256.convert(utf8.encode('MySecureFixedKey')).bytes;
    // Use only the first 16 bytes -> AES-128
    return enc.Key(Uint8List.fromList(digest.sublist(0, 16)));
  }();

  static final enc.Encrypter _encrypter = enc.Encrypter(
    enc.AES(_key, mode: enc.AESMode.cbc, padding: 'PKCS7'),
  );

  // ---- Bytes ----

  static Uint8List encryptFingerPrint(Uint8List data) {
    return _encrypter.encryptBytes(data, iv: _iv).bytes;
  }

  static Uint8List decryptFingerPrint(Uint8List data) {
    final decrypted = _encrypter.decryptBytes(enc.Encrypted(data), iv: _iv);
    return Uint8List.fromList(decrypted);
  }

  // ---- Strings ----

  /// Returns Base64 (standard alphabet, no line wrapping = Android NO_WRAP).
  static String encryptString(String data) {
    final encrypted = _encrypter.encryptBytes(utf8.encode(data), iv: _iv);
    return base64Encode(encrypted.bytes);
  }

  static String decryptString(String data) {
    final decrypted = _encrypter.decryptBytes(
      enc.Encrypted(base64Decode(data)),
      iv: _iv,
    );
    return _trimIndent(utf8.decode(decrypted));
  }

  /// Mirrors Kotlin's String.trimIndent(), which the original applied after
  /// decrypting. For normal single-line values this just strips leading
  /// whitespace. Remove this call if you don't need exact parity.
  static String _trimIndent(String value) {
    final lines = value.split(RegExp(r'\r\n|\r|\n'));
    final nonBlank = lines.where((l) => l.trim().isNotEmpty);
    if (nonBlank.isEmpty) return lines.length <= 2 ? '' : lines.sublist(1, lines.length - 1).join('\n');

    int indentOf(String l) => l.length - l.trimLeft().length;
    final minIndent = nonBlank.map(indentOf).reduce((a, b) => a < b ? a : b);

    var result = List<String>.from(lines);
    if (result.isNotEmpty && result.first.trim().isEmpty) result.removeAt(0);
    if (result.isNotEmpty && result.last.trim().isEmpty) result.removeLast();

    return result
        .map((l) => l.length >= minIndent ? l.substring(minIndent) : l)
        .join('\n');
  }
}


extension ByteArrayBase64 on Uint8List {
  // Base64.NO_WRAP: Dart's encoder never inserts line breaks, so this matches.
  String toBase64() => base64Encode(this);
}

extension StringBase64 on String {
  Uint8List fromBase64() => base64Decode(base64.normalize(this));
}



