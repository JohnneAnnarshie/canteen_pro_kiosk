import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/request_type.dart';
import 'api_urls.dart';

typedef GetAccessToken = Future<String?> Function();
typedef RefreshToken = Function();
typedef GetCompanyReference = String? Function();
typedef GetAppAuth = Function();
typedef GetTokenExpired = bool Function();

class ApiService {
  ApiService(
      {required this.baseUrl,
      required this.getAccessToken,
      required this.refreshToken,
      required this.getAppAuth,
      required this.forceLogout,
      required this.getCompanyReference,
        this.id = '',
        this.type = '',
        this.status = '',
      });
  final String baseUrl;
  final GetAccessToken getAccessToken;
  final RefreshToken refreshToken;
  final GetAppAuth getAppAuth;
  final void Function() forceLogout;
  final GetCompanyReference getCompanyReference;
  final String id;
  final String type;
  final String status;

  var count = 0;

  Future<Map<bool, dynamic>> _handleResponse(http.Response response) async {
    switch (response.statusCode) {
      case 200:
        return {true: jsonDecode(response.body.isEmpty ? '{}' : response.body)};
      case 201:
        return {true: jsonDecode(response.body)};
      case 204:///\\\
        return {true: response.body.isEmpty ? "Empty" : jsonDecode(response.body)};
      case 400:
        return {false: response.body.isEmpty ? "Empty" : jsonDecode(response.body)};
      case 401:
        await refreshToken();
        return {false: 'Unauthorized, Retry'};
      case 403:
        return {false: 'Unauthorized to do this action'};
      case 404:
        return {false: 'Resource not found'};
      case 500:
        return {false: 'An error occurred on the server'};
      case 502:
        return {false: 'Error (502): Bad Gateway'};
      case 503:
        return {false: 'Service Unavailable'};
      case 504:
        return {false: 'Gateway Timeout'};
      case 505:
        return {false: 'HTTP Version Not Supported'};
      default:
        throw Exception('An error occurred');
    }
  }

  Future<Map<bool, dynamic>> request(
      {RequestType requestType = RequestType.get,
        bool isSecondary = false,
        String accessToken = '',
      required String endPoint,
      dynamic body,
      String? replaceBaseUrl}) async {
    try {
      await getAppAuth();
      final headers = {
        'Company-Reference' : getCompanyReference() ?? '',
        'Application-ID' : applicationId,
        'Content-Type': isSecondary ? 'application/x-www-form-urlencoded' : 'application/json',
        'Authorization': isSecondary ? 'Bearer $accessToken' : 'Bearer ${ await getAccessToken()}'
      };
      http.Response response;
      final baseUrl = this.baseUrl;
      final encodedBody = isSecondary ? body : jsonEncode(body);
      final url = replaceBaseUrl == null
          ? '$baseUrl$endPoint'
          : '$replaceBaseUrl$endPoint';
      if (kDebugMode) {
       debugPrint('______________________________________________');
       debugPrint('accessToken: ${isSecondary ? accessToken : await getAccessToken()}');
       debugPrint('companyReference: ${getCompanyReference()}');
       debugPrint('requestType: $requestType');
       debugPrint('baseUrl: $baseUrl');
       debugPrint('endPoint: $endPoint');
       debugPrint('final url: $url');
       debugPrint('headers: $headers');
       debugPrint('body: $body');
      }

      switch (requestType) {
        case RequestType.get:
          response = await http.get(Uri.parse(url), headers: headers);
        case RequestType.post:
          response = await http.post(Uri.parse(url),
              headers: headers, body: encodedBody);
        case RequestType.put:
          response = await http.put(Uri.parse(url),
              headers: headers, body: encodedBody);
        case RequestType.delete:
          response = await http.delete(Uri.parse(url),
              headers: headers, body: encodedBody);
      }
      if (kDebugMode) {
       debugPrint('statusCode: ${response.statusCode}');
       debugPrint('response: ${response.body}');
       debugPrint('______________________________________________');
      }
      if (response.statusCode == 401) {
          count++;
          await refreshToken();
          if (count < 2) {
            final res2 = await request(
                requestType: requestType,
                endPoint: endPoint,
                body: body,
                replaceBaseUrl: replaceBaseUrl);
            return res2;
          } else if (count > 2) {
            forceLogout();
            return {false: 'Unauthorized, Retry'};
          }
      }
      return _handleResponse(response);
    } catch (e, s) {
      if (kDebugMode) {
       debugPrint(e.toString());
       debugPrintStack(stackTrace: s);
      }
      return {false: 'An error occurred'};
    }
  }
}
