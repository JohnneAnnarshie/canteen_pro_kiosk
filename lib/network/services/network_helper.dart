import 'dart:convert';

import 'package:canteen_pro/network/auth_service.dart';
import 'package:canteen_pro/network/repos/network_config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/app_env.dart';
import 'auth_session_service.dart';

class NetworkHelper {
  NetworkHelper._();
  factory NetworkHelper() => NetworkHelper._();

  static final NetworkConfig _networkConfig = NetworkConfig();
  static String get baseUrl => AppEnv.apiBaseUrl;
  static String get userInfoEndpoint => AppEnv.userInfoUrl;
  final AuthService _appAuth = _networkConfig.authService;
  static String? _lastLoggedAccessToken;

  static const int _maxLogBodyLength = 2000;

  static void _debugLog(String message) {
    if (kDebugMode) debugPrint('[NetworkHelper] $message');
  }

  static void _logError(String method, Uri url, dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      _debugLog('ERROR: $method $url - $error');
      if (stackTrace != null) _debugLog('$stackTrace');
    }
  }

  /// Try to decode one JWT part (header/payload) into a JSON map.
  static Map<String, dynamic>? _tryDecodeJwtPart(String part) {
    try {
      final normalized = base64Url.normalize(part);
      final decodedBytes = base64Url.decode(normalized);
      final decodedStr = utf8.decode(decodedBytes);
      final json = jsonDecode(decodedStr);
      if (json is Map<String, dynamic>) return json;
    } catch (_) {}
    return null;
  }

  /// Debug-only token decoder: logs JWT header & payload once per token value.
  static void _logDecodedAccessToken(String? accessToken) {
    if (!kDebugMode) return;
    if (accessToken == null || accessToken.isEmpty) return;
    if (_lastLoggedAccessToken == accessToken) return;
    _lastLoggedAccessToken = accessToken;

    final parts = accessToken.split('.');
    if (parts.length != 3) {
      _debugLog('Access token is not a JWT; decode skipped.');
      return;
    }

    final header = _tryDecodeJwtPart(parts[0]);
    final payload = _tryDecodeJwtPart(parts[1]);
    _debugLog('Decoded access token header: $header');
    _debugLog('Decoded access token payload: $payload');
    _debugLog(
      'Decoded claims -> psp_id: ${payload?['psp_id']}, psp_type: ${payload?['psp_type']}',
    );
  }

  /// Mask Authorization header value for safe debug logging.
  static Map<String, String> _maskHeaders(Map<String, String> headers) {
    return headers.map((k, v) {
      if (k.toLowerCase() == 'authorization') {
        return MapEntry(k, v.length > 20 ? '${v.substring(0, 15)}...' : '***');
      }
      return MapEntry(k, v);
    });
  }

  static void _logRequest(String method, Uri url, Map<String, String> headers, Object? body) {
    _debugLog('--- API Request ---');
    _debugLog('Method: $method');
    _debugLog('URL: $url');
    _debugLog('Headers: ${_maskHeaders(headers)}');
    if (body != null) {
      final str = body is String ? body : jsonEncode(body);
      final truncated = str.length > _maxLogBodyLength
          ? '${str.substring(0, _maxLogBodyLength)}... [truncated ${str.length} chars]'
          : str;
      _debugLog('Payload: $truncated');
    } else {
      _debugLog('Payload: (none)');
    }
    _debugLog('-------------------');
  }

  static void _logResponse(String method, Uri url, int statusCode, String body) {
    _debugLog('--- API Response ---');
    _debugLog('Method: $method');
    _debugLog('URL: $url');
    _debugLog('Status: $statusCode');
    final truncated = body.length > _maxLogBodyLength
        ? '${body.substring(0, _maxLogBodyLength)}... [truncated ${body.length} chars]'
        : body;
    _debugLog('Body: $truncated');
    _debugLog('--------------------');
  }

  static Future<bool> _isTokenExpired() async {
    final expiration = await AuthSessionService.getAccessTokenExpiration();
    if (expiration == null) return true;
    final now = DateTime.now();
    return expiration.isBefore(now.add(const Duration(minutes: 5)));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await AuthSessionService.getRefreshToken();
      if (refreshToken == null) return false;
      final result = await _appAuth.refresh(refreshToken);
      AuthSessionService.saveTokens(auth: result);
      return false;
    } catch (e, stackTrace) {
      _logError('TOKEN_REFRESH', Uri.parse(AppEnv.discoveryUrl), e, stackTrace);
      // Refresh token expired or revoked (e.g. invalid_grant). Clear session so
      // user is sent to login and can sign in again.
      await AuthSessionService.clearSessionDueToRefreshFailure();
      return false;
    }
  }

  Future<String?> _ensureValidToken() async {
    if (await _isTokenExpired()) {
      final refreshed = await _refreshToken();
      if (!refreshed) return null;
    }
    final token = await AuthSessionService.getAccessToken();
    final cleaned = _cleanToken(token);
    _logDecodedAccessToken(cleaned);
    return cleaned;
  }

  /// Remove "Bearer " prefix if present so we never double-prefix in headers.
  static String? _cleanToken(String? token) {
    if (token == null) return null;
    return token.startsWith('Bearer ') ? token.substring(7) : token;
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    final token = await _ensureValidToken();
    if (token == null) {
      throw Exception('No valid access token. Please login again.');
    }
    final url = Uri.parse(userInfoEndpoint);
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    _logRequest('GET', url, headers, null);
    try {
      final response = await http.get(url, headers: headers);
      _logResponse('GET', url, response.statusCode, response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to get user info: ${response.statusCode} - ${response.body}');
    } catch (e, st) {
      _logError('GET', url, e, st);
      rethrow;
    }
  }

  /// GET request to CRM API (path is relative to baseUrl, e.g. 'Plans?Status=approved').
  Future<Map<String, dynamic>> get(String path) async {
    final token = await _ensureValidToken();
    if (token == null) {
      throw Exception('No valid access token. Please login again.');
    }
    final url = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Company-Reference': _networkConfig.getCompanyReference() ?? '',
      'Accept': 'application/json',
    };
    _logRequest('GET', url, headers, null);
    try {
      var response = await http.get(url, headers: headers);
      _logResponse('GET', url, response.statusCode, response.body);

      // If token expired during request, refresh and retry at most once
      if (response.statusCode == 401) {
        _debugLog('401 received, attempting token refresh...');
        final refreshed = await _refreshToken();
        if (refreshed) {
          final newToken = _cleanToken(await AuthSessionService.getAccessToken());
          if (newToken != null && newToken.isNotEmpty) {
            headers['Authorization'] = 'Bearer $newToken';
            _debugLog('Retrying GET once with new token...');
            response = await http.get(url, headers: headers);
            _logResponse('GET', url, response.statusCode, response.body);
          } else {
            _debugLog('Token refresh succeeded but no new token available');
          }
        } else {
          _debugLog('Token refresh failed, returning 401');
        }
      }

      if (response.statusCode != 200) {
        throw Exception('Request failed: ${response.statusCode} - ${response.body}');
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e, st) {
      _logError('GET', url, e, st);
      rethrow;
    }
  }

  /// GET request that returns a JSON array ().
  Future<List<dynamic>> getList(String path) async {
    final token = await _ensureValidToken();
    if (token == null) {
      throw Exception('No valid access token. Please login again.');
    }
    final url = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Company-Reference': _networkConfig.getCompanyReference() ?? '',
      'Accept': 'application/json',
    };
    _logRequest('GET', url, headers, null);
    try {
      var response = await http.get(url, headers: headers);
      _logResponse('GET', url, response.statusCode, response.body);

      // If token expired during request, refresh and retry at most once
      if (response.statusCode == 401) {
        _debugLog('401 received, attempting token refresh...');
        final refreshed = await _refreshToken();
        if (refreshed) {
          final newToken = _cleanToken(await AuthSessionService.getAccessToken());
          if (newToken != null && newToken.isNotEmpty) {
            headers['Authorization'] = 'Bearer $newToken';
            _debugLog('Retrying GET once with new token...');
            response = await http.get(url, headers: headers);
            _logResponse('GET', url, response.statusCode, response.body);
          } else {
            _debugLog('Token refresh succeeded but no new token available');
          }
        } else {
          _debugLog('Token refresh failed, returning 401');
        }
      }

      if (response.statusCode != 200) {
        throw Exception('Request failed: ${response.statusCode} - ${response.body}');
      }
      return jsonDecode(response.body) as List<dynamic>;
    } catch (e, st) {
      _logError('GET', url, e, st);
      rethrow;
    }
  }


  /// POST request to CRM API. [endpoint] is relative to baseUrl (e.g. 'Plans').
  Future<http.Response> post(String endpoint, { Map<String, String>? headers, Object? body }) async {
    final token = await _ensureValidToken();
    if (token == null) {
      throw Exception('No valid access token. Please login again.');
    }
    final url = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Company-Reference': _networkConfig.getCompanyReference() ?? '',
      'Accept': 'application/json',
      ...?headers,
    };
    final bodyString = body != null ? jsonEncode(body) : null;
    _logRequest('POST', url, requestHeaders, bodyString);
    try {
      var response = await http.post(url, headers: requestHeaders, body: bodyString);
      _logResponse('POST', url, response.statusCode, response.body);

      // If token expired during request, refresh and retry at most once
      if (response.statusCode == 401) {
        _debugLog('401 received, attempting token refresh...');
        final refreshed = await _refreshToken();
        if (refreshed) {
          final newToken = _cleanToken(await AuthSessionService.getAccessToken());
          if (newToken != null && newToken.isNotEmpty) {
            requestHeaders['Authorization'] = 'Bearer $newToken';
            _debugLog('Retrying POST once with new token...');
            response = await http.post(url, headers: requestHeaders, body: bodyString);
            _logResponse('POST', url, response.statusCode, response.body);
          } else {
            _debugLog('Token refresh succeeded but no new token available');
          }
        } else {
          _debugLog('Token refresh failed, returning 401');
        }
      }

      return response;
    } catch (e, st) {
      _logError('POST', url, e, st);
      rethrow;
    }
  }

  /// PUT request to CRM API.
  Future<http.Response> put(String endpoint, { Map<String, String>? headers, Object? body }) async {
    final token = await _ensureValidToken();
    if (token == null) {
      throw Exception('No valid access token. Please login again.');
    }
    final url = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Company-Reference': _networkConfig.getCompanyReference() ?? '',
      'Accept': 'application/json',
      ...?headers,
    };
    final bodyString = body != null ? jsonEncode(body) : null;
    _logRequest('PUT', url, requestHeaders, bodyString);
    try {
      var response = await http.put(url, headers: requestHeaders, body: bodyString);
      _logResponse('PUT', url, response.statusCode, response.body);

      // If token expired during request, refresh and retry at most once
      if (response.statusCode == 401) {
        _debugLog('401 received, attempting token refresh...');
        final refreshed = await _refreshToken();
        if (refreshed) {
          final newToken = _cleanToken(await AuthSessionService.getAccessToken());
          if (newToken != null && newToken.isNotEmpty) {
            requestHeaders['Authorization'] = 'Bearer $newToken';
            _debugLog('Retrying PUT once with new token...');
            response = await http.put(url, headers: requestHeaders, body: bodyString);
            _logResponse('PUT', url, response.statusCode, response.body);
          } else {
            _debugLog('Token refresh succeeded but no new token available');
          }
        } else {
          _debugLog('Token refresh failed, returning 401');
        }
      }

      return response;
    } catch (e, st) {
      _logError('PUT', url, e, st);
      rethrow;
    }
  }

}
