class ServerUser {
  final String? id;
  final String? name;
  final String? email;
  final String? username;
  final String? companyReference;

  const ServerUser({
    this.id,
    this.name,
    this.email,
    this.username,
    this.companyReference,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'username': username,
    'companyReference': companyReference,
  };

  factory ServerUser.fromJson(Map<String, dynamic> json) => ServerUser(
    id: json['id']?.toString(),
    name: json['name']?.toString(),
    email: json['email']?.toString(),
    username: json['username']?.toString(),
    companyReference: json['companyReference']?.toString(),
  );

  static List<ServerUser> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map((item) => ServerUser.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  ServerUser copyWith({
    String? id,
    String? name,
    String? email,
    String? username,
    String? companyReference,
  }) => ServerUser(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    username: username ?? this.username,
    companyReference: companyReference ?? this.companyReference,
  );
}

extension ServerUserSetExtensions on ServerUser {
  Set<String> get toStringSet => {
    id ?? '',
    name ?? '',
    email ?? '',
    username ?? '',
    companyReference ?? '',
  };
}

extension StringSetServerUserExtensions on Set<String> {
  ServerUser get toServerUser {
    final values = toList();
    return ServerUser(
      id: values.isNotEmpty ? values[0] : null,
      name: values.length > 1 ? values[1] : null,
      email: values.length > 2 ? values[2] : null,
      username: values.length > 3 ? values[3] : null,
      companyReference: values.length > 4 ? values[4] : null,
    );
  }
}
