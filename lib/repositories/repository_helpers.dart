import 'dart:convert';

import 'package:http/http.dart' as http;

Map<String, dynamic> requireJsonMap(http.Response response) {
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      'Request failed: ${response.statusCode} - ${response.body}',
    );
  }

  final decoded = jsonDecode(response.body);
  if (decoded is! Map) {
    throw const FormatException('Expected a JSON object response');
  }
  return Map<String, dynamic>.from(decoded);
}

void requireSuccess(http.Response response) {
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      'Request failed: ${response.statusCode} - ${response.body}',
    );
  }
}

Map<String, dynamic> asJsonMap(dynamic value) {
  if (value is! Map) {
    throw const FormatException('Expected a JSON object');
  }
  return Map<String, dynamic>.from(value);
}

List<dynamic> asJsonList(dynamic value) {
  if (value is! List) {
    throw const FormatException('Expected a JSON array');
  }
  return value;
}
