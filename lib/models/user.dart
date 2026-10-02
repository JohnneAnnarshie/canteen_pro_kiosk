class User {
  final String sub;
  final String email;
  final String givenName;
  final String familyName;
  final String preferredUsername;
  final String name;
  final String accRef;

  User({
    required this.sub,
    required this.email,
    required this.givenName,
    required this.familyName,
    required this.preferredUsername,
    required this.name,
    required this.accRef,
  });

  Map<String, dynamic> toJson() {
    return {
      'sub': sub,
      'email': email,
      'given_name': givenName,
      'family_name': familyName,
      'preferred_username': preferredUsername,
      'name': name,
      'acc_ref': accRef,
    };
  }

  //"sub":"c1fee00d-09d1-4ed6-8ea8-12e482efc000",
  // "email":"WILLIAM.ANTWI-BOASIAKO@PERSOL.NET",
  // "name":"Persol Frontend",
  // "given_name":"Persol",
  // "family_name":"Frontend",
  // "preferred_username":"frontend_00000097"
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      sub: json['sub'] ?? '',
      email: json['email'] ?? '',
      givenName: json['given_name'] ?? '',
      familyName: json['family_name'] ?? '',
      preferredUsername: json['preferred_username'] ?? '',
      name: json['name'] ?? '',
      accRef: json['acc_ref'] ?? '',
    );
  }

  User copyWith({
    String? sub,
    String? email,
    String? fullName,
    String? givenName,
    String? familyName,
    String? preferredUsername,
    String? name,
    String? accRef,
  }) {
    return User(
      sub: sub ?? this.sub,
      email: email ?? this.email,
      givenName: givenName ?? this.givenName,
      familyName: familyName ?? this.familyName,
      preferredUsername: preferredUsername ?? this.preferredUsername,
      name: name ?? this.name,
      accRef: accRef ?? this.accRef,
    );
  }
}

final sampleUser = User(
  sub: 'user_001',
  email: 'company_001',
  givenName: 'Jackson Briggs',
  familyName: 'Special Forces',
  preferredUsername: 'acc_ref_001',
  name: 'Jackson',
  accRef: 'acc_ref_001',
);

