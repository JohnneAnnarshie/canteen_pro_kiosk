import 'user_category.dart';

class Member {
  final String id;
  final String staffId;
  final String fullName;
  final String email;
  final int role;
  final String categoryId;
  final String? tagId;
  final String? nfcReference;
  final String? faceRecognitionReference;
  final String? fingerprintReference;
  final String? businessUnitId;
  final String billingEntityId;
  final bool status;
  final MemberCategory? userCategory;

  const Member({
    required this.id,
    required this.staffId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.categoryId,
    this.tagId,
    this.nfcReference,
    this.faceRecognitionReference,
    this.fingerprintReference,
    this.businessUnitId,
    required this.billingEntityId,
    required this.status,
    this.userCategory,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'staffId': staffId,
    'fullName': fullName,
    'email': email,
    'role': role,
    'categoryId': categoryId,
    'tagId': tagId,
    'nfcReference': nfcReference,
    'faceRecognitionReference': faceRecognitionReference,
    'fingerprintReference': fingerprintReference,
    'businessUnitId': businessUnitId,
    'billingEntityId': billingEntityId,
    'status': status,
    'userCategory': userCategory?.toJson(),
  };

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    id: json['id']?.toString() ?? '',
    staffId: json['staffId']?.toString() ?? '',
    fullName: json['fullName']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    role: _intValue(json['role']),
    categoryId: json['categoryId']?.toString() ?? '',
    tagId: json['tagId']?.toString(),
    nfcReference: json['nfcReference']?.toString(),
    faceRecognitionReference: json['faceRecognitionReference']?.toString(),
    fingerprintReference: json['fingerprintReference']?.toString(),
    businessUnitId: json['businessUnitId']?.toString(),
    billingEntityId: json['billingEntityId']?.toString() ?? '',
    status: _boolValue(json['status'])
    // userCategory:
    //     json['userCategory'] is Map
    //         ? UserCategory.fromJson(
    //           Map<String, dynamic>.from(json['userCategory']),
    //         )
    //         : null,
  );

  static List<Member> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map((item) => Member.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  Member copyWith({
    String? id,
    String? staffId,
    String? fullName,
    String? email,
    int? role,
    String? categoryId,
    String? tagId,
    String? nfcReference,
    String? faceRecognitionReference,
    String? fingerprintReference,
    String? businessUnitId,
    String? billingEntityId,
    bool? status,
    MemberCategory? userCategory,
  }) => Member(
    id: id ?? this.id,
    staffId: staffId ?? this.staffId,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    role: role ?? this.role,
    categoryId: categoryId ?? this.categoryId,
    tagId: tagId ?? this.tagId,
    nfcReference: nfcReference ?? this.nfcReference,
    faceRecognitionReference:
        faceRecognitionReference ?? this.faceRecognitionReference,
    fingerprintReference: fingerprintReference ?? this.fingerprintReference,
    businessUnitId: businessUnitId ?? this.businessUnitId,
    billingEntityId: billingEntityId ?? this.billingEntityId,
    status: status ?? this.status,
    userCategory: userCategory ?? this.userCategory,
  );
}

class UserSecurityItem {
  final String employeeId;
  final String? nfcReference;
  final String? faceRecognitionReference;
  final String? fingerprintReference;

  const UserSecurityItem({
    required this.employeeId,
    this.nfcReference,
    this.faceRecognitionReference,
    this.fingerprintReference,
  });

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'nfcReference': nfcReference,
    'faceRecognitionReference': faceRecognitionReference,
    'fingerprintReference': fingerprintReference,
  };

  factory UserSecurityItem.fromJson(Map<String, dynamic> json) => UserSecurityItem(
    employeeId: json['employeeId']?.toString() ?? '',
    nfcReference: json['nfcReference']?.toString(),
    faceRecognitionReference: json['faceRecognitionReference']?.toString(),
    fingerprintReference: json['fingerprintReference']?.toString(),
  );

  static List<UserSecurityItem> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map((item) => UserSecurityItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  UserSecurityItem copyWith({
    String? employeeId,
    String? nfcReference,
    String? faceRecognitionReference,
    String? fingerprintReference,
  }) => UserSecurityItem(
    employeeId: employeeId ?? this.employeeId,
    nfcReference: nfcReference ?? this.nfcReference,
    faceRecognitionReference:
        faceRecognitionReference ?? this.faceRecognitionReference,
    fingerprintReference: fingerprintReference ?? this.fingerprintReference,
  );
}

class UserSecurity {
  final List<UserSecurityItem> staffSecurities;

  const UserSecurity({required this.staffSecurities});

  Map<String, dynamic> toJson() => {
    'staffSecurities': staffSecurities.map((item) => item.toJson()).toList(),
  };

  factory UserSecurity.fromJson(Map<String, dynamic> json) => UserSecurity(
    staffSecurities:
        json['staffSecurities'] is List
            ? UserSecurityItem.fromJsonList(json['staffSecurities'])
            : <UserSecurityItem>[],
  );

  static List<UserSecurity> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map((item) => UserSecurity.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  UserSecurity copyWith({List<UserSecurityItem>? staffSecurities}) =>
      UserSecurity(staffSecurities: staffSecurities ?? this.staffSecurities);
}

class UserApiResponse {
  final List<Member> items;
  final int currentPage;
  final int resultsPerPage;
  final int totalPages;
  final int totalResults;
  final bool empty;

  const UserApiResponse({
    required this.items,
    required this.currentPage,
    required this.resultsPerPage,
    required this.totalPages,
    required this.totalResults,
    required this.empty,
  });

  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
    'currentPage': currentPage,
    'resultsPerPage': resultsPerPage,
    'totalPages': totalPages,
    'totalResults': totalResults,
    'empty': empty,
  };

  factory UserApiResponse.fromJson(Map<String, dynamic> json) =>
      UserApiResponse(
        items:
            json['items'] is List
                ? Member.fromJsonList(json['items'])
                : <Member>[],
        currentPage: _intValue(json['currentPage']),
        resultsPerPage: _intValue(json['resultsPerPage']),
        totalPages: _intValue(json['totalPages']),
        totalResults: _intValue(json['totalResults']),
        empty: _boolValue(json['empty']),
      );

  static List<UserApiResponse> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => UserApiResponse.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  UserApiResponse copyWith({
    List<Member>? items,
    int? currentPage,
    int? resultsPerPage,
    int? totalPages,
    int? totalResults,
    bool? empty,
  }) => UserApiResponse(
    items: items ?? this.items,
    currentPage: currentPage ?? this.currentPage,
    resultsPerPage: resultsPerPage ?? this.resultsPerPage,
    totalPages: totalPages ?? this.totalPages,
    totalResults: totalResults ?? this.totalResults,
    empty: empty ?? this.empty,
  );
}

int _intValue(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

bool _boolValue(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}

extension CanteenUserExtensions on Member {
  UserSecurityItem toUserItem() => UserSecurityItem(
    employeeId: id,
    nfcReference: nfcReference,
    faceRecognitionReference: faceRecognitionReference,
    fingerprintReference: fingerprintReference,
  );
}

final List<Member> sampleMembers = const [
  Member(
    id: 'member_001',
    staffId: 'STAFF-001',
    fullName: 'Ama Boateng',
    email: 'ama.boateng@company.com',
    role: 1,
    categoryId: 'cat_staff',
    tagId: 'TAG-001',
    nfcReference: 'NFC-001',
    faceRecognitionReference: 'FACE-001',
    fingerprintReference: 'FPR-001',
    businessUnitId: 'BU-001',
    billingEntityId: 'billing_001',
    status: true,
    userCategory: MemberCategory(
      id: 'cat_staff',
      code: 'STAFF',
      name: 'Staff',
      canteenIds: ['canteen_001', 'canteen_002'],
      serviceProviderIds: ['provider_001'],
      coFundingType: 'none',
      coFundingValue: 0.0,
      mealsPerServing: 1,
      allowIndividualPreference: true,
      mandatoryPreorder: false,
      status: true,
    ),
  ),
  Member(
    id: 'member_002',
    staffId: 'STAFF-002',
    fullName: 'Kwame Mensah',
    email: 'kwame.mensah@company.com',
    role: 2,
    categoryId: 'cat_manager',
    tagId: 'TAG-002',
    nfcReference: 'NFC-002',
    faceRecognitionReference: 'FACE-002',
    fingerprintReference: 'FPR-002',
    businessUnitId: 'BU-002',
    billingEntityId: 'billing_001',
    status: true,
    userCategory: MemberCategory(
      id: 'cat_manager',
      code: 'MGR',
      name: 'Manager',
      canteenIds: ['canteen_001', 'canteen_003'],
      serviceProviderIds: ['provider_001', 'provider_002'],
      coFundingType: 'partial',
      coFundingValue: 25.0,
      mealsPerServing: 2,
      allowIndividualPreference: true,
      mandatoryPreorder: true,
      status: true,
    ),
  ),
  Member(
    id: 'member_003',
    staffId: 'STAFF-003',
    fullName: 'Efua Addo',
    email: 'efua.addo@company.com',
    role: 1,
    categoryId: 'cat_staff',
    tagId: 'TAG-003',
    nfcReference: 'NFC-003',
    faceRecognitionReference: 'FACE-003',
    fingerprintReference: 'FPR-003',
    businessUnitId: 'BU-003',
    billingEntityId: 'billing_002',
    status: false,
    userCategory: MemberCategory(
      id: 'cat_staff',
      code: 'STAFF',
      name: 'Staff',
      canteenIds: ['canteen_002', 'canteen_003'],
      serviceProviderIds: ['provider_003'],
      coFundingType: 'none',
      coFundingValue: 0.0,
      mealsPerServing: 1,
      allowIndividualPreference: false,
      mandatoryPreorder: false,
      status: true,
    ),
  ),
];
