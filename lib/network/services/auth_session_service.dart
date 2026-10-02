import 'dart:convert';

import 'package:canteen_pro/network/repos/network_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/auth.dart';

class AuthSessionService {
  AuthSessionService._();
  static final AuthSessionService _instance = AuthSessionService._();
  static AuthSessionService get instance => _instance;
  factory AuthSessionService() => AuthSessionService._();
  static final _storage = NetworkConfig().prefsRepo.storage;

  /// Notifies when session was cleared due to token refresh failure (e.g. refresh token expired).
  /// GoRouter uses this as [refreshListenable] to re-run redirect and send user to login.
  static final ValueNotifier<bool> sessionExpiredNotifier = ValueNotifier<bool>(false);

  /// Set when session is cleared due to refresh failure; landing page shows it once then clears.
  static String? sessionExpiredMessage;
  static const String _lastLoginDateKey = 'last_login_date';
  static const String _accessTokenKey = 'access_token';
  static const String _idTokenKey = 'id_token';
  static const String _accessTokenExpirationKey = 'access_token_expiration';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userInfoKey = 'user_info';

  static Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final clean = token.startsWith('Bearer ') ? token.substring(7) : token;
      final parts = clean.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final decodedBytes = base64Url.decode(normalized);
      final decodedString = utf8.decode(decodedBytes);
      final map = jsonDecode(decodedString);
      if (map is Map<String, dynamic>) return map;
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isLoggedInToday() async {
    try {
      final lastLoginDateStr = await _storage.read(key: _lastLoginDateKey);
      if (lastLoginDateStr == null) return false;
      final lastLoginDate = DateTime.parse(lastLoginDateStr);
      final today = DateTime.now();
      return lastLoginDate.year == today.year &&
          lastLoginDate.month == today.month &&
          lastLoginDate.day == today.day;
    } catch (e) {
      return false;
    }
  }

  static Future<void> saveLoginDate() async {
    try {
      await _storage.write(
          key: _lastLoginDateKey, value: DateTime.now().toIso8601String());
    } catch (e) {
      print('Error saving login date: $e');
    }
  }

  static Future<void> saveTokens({
    required Auth? auth,
  }) async {
    try {
      if (auth?.accessToken != null) {
        await _storage.write(key: _accessTokenKey, value: auth!.accessToken);
        final payload = _decodeJwtPayload(auth.accessToken);
        if (payload != null) {

        }
      }
      if (auth?.idToken != null) await _storage.write(key: _idTokenKey, value: auth!.idToken);
      if (auth?.expiryDate != null) {
        await _storage.write(
            key: _accessTokenExpirationKey,
            value: auth!.expiryDate.toIso8601String());
      }
      if (auth?.refreshToken != null) await _storage.write(key: _refreshTokenKey, value: auth!.refreshToken);
    } catch (e) {
      print('Error saving tokens: $e');
    }
  }

  static Future<Auth?> getAuth() async {
    try {
      final accessToken = await getAccessToken();
      final idToken = await getIdToken();
      final expiryDate = await getAccessTokenExpiration();
      final refreshToken = await getRefreshToken();

      if (accessToken != null && idToken != null && expiryDate != null && refreshToken != null) {
        return Auth(accessToken, idToken, '', refreshToken, expiryDate);
      }
    } catch (e) {
      print('Error reading auth: $e');
    }
    return null;
  }

  static Future<String?> getCompanyReference() async {
    try {
      final userInfo = await getUserInfo();
      if (userInfo != null) {
        return userInfo['acc_ref'] as String;
      }
    } catch (e) {
      print('Error reading company reference: $e');
    }
  }

  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      print('Error reading access token: $e');
      return null;
    }
  }

  static Future<String?> getIdToken() async {
    try {
      return await _storage.read(key: _idTokenKey);
    } catch (e) {
      print('Error reading ID token: $e');
      return null;
    }
  }

  static Future<DateTime?> getAccessTokenExpiration() async {
    try {
      final expirationStr = await _storage.read(key: _accessTokenExpirationKey);
      if (expirationStr != null) return DateTime.parse(expirationStr);
      return null;
    } catch (e) {
      print('Error reading access token expiration: $e');
      return null;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      print('Error reading refresh token: $e');
      return null;
    }
  }

  static Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    try {
      await _storage.write(key: _userInfoKey, value: jsonEncode(userInfo));
    } catch (e) {
      print('Error saving user info: $e');
    }
  }

  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final userInfoJson = await _storage.read(key: _userInfoKey);
      if (userInfoJson != null) return jsonDecode(userInfoJson) as Map<String, dynamic>;
      return null;
    } catch (e) {
      print('Error reading user info: $e');
      return null;
    }
  }


  static Future<void> clearAll() async {
    try {
      await _storage.delete(key: _lastLoginDateKey);
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _idTokenKey);
      await _storage.delete(key: _accessTokenExpirationKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userInfoKey);
    } catch (e) {
      print('Error clearing authentication data: $e');
    }
  }

  /// Call when token refresh fails (e.g. invalid_grant). Clears session and notifies
  /// so the app can redirect to login.
  static Future<void> clearSessionDueToRefreshFailure() async {
    await clearAll();
    sessionExpiredMessage = 'Your session has expired. Please sign in again.';
    sessionExpiredNotifier.value = true;
  }
}
