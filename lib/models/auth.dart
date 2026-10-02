class Auth {
  Auth(
    this.accessToken,
    this.idToken,
    this.tokenType,
    this.refreshToken,
    this.expiryDate,
  );
  final String accessToken;
  final String idToken;
  final String tokenType;
  final String refreshToken;
  final DateTime expiryDate;

  Map<String, dynamic> toMap() {
    return {
      'accessToken': accessToken,
      'idToken': idToken,
      'tokenType': tokenType,
      'refreshToken': refreshToken,
      'accessTokenExpirationDateTime': expiryDate.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'id_token': idToken,
      'token_type': tokenType,
      'refresh_token': refreshToken,
      'expires_in': expiryDate.toIso8601String(),
    };
  }

  static fromMap(Map<String, dynamic> json) {
    return Auth(
      json['accessToken'] ?? '',
      json['idToken'] ?? '',
      json['tokenType'] ?? '',
      json['refreshToken'] ?? '',
      DateTime.parse(
        json['accessTokenExpirationDateTime'] ??
            DateTime.now().toIso8601String(),
      ),
    );
  }

  static fromWebJson(Map<String, dynamic> json) {
    return Auth(
      json['access_token'] ?? '',
      json['id_token'] ?? '',
      json['token_type'] ?? '',
      json['refresh_token'] as String,
      DateTime.now().add(Duration(seconds: json['expires_in'] as int)),
    );
  }

  static fromJson(Map<String, dynamic> json) {
    return Auth(
      json['access_token'] ?? '',
      json['id_token'] ?? '',
      json['token_type'] ?? '',
      json['refresh_token'] ?? '',
      DateTime.parse(json['expires_in'] ?? DateTime.now().toIso8601String()),
    );
  }
}
