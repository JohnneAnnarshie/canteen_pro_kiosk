class MemberCategory {
  final String id;
  final String code;
  final String name;
  final List<String> canteenIds;
  final List<String>? serviceProviderIds;
  final String coFundingType;
  final double coFundingValue;
  final int mealsPerServing;
  final bool allowIndividualPreference;
  final bool mandatoryPreorder;
  final bool status;

  const MemberCategory({
    required this.id,
    required this.code,
    required this.name,
    required this.canteenIds,
    this.serviceProviderIds,
    required this.coFundingType,
    required this.coFundingValue,
    required this.mealsPerServing,
    required this.allowIndividualPreference,
    required this.mandatoryPreorder,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'canteenIds': canteenIds,
    'serviceProviderIds': serviceProviderIds,
    'coFundingType': coFundingType,
    'coFundingValue': coFundingValue,
    'mealsPerServing': mealsPerServing,
    'allowIndividualPreference': allowIndividualPreference,
    'mandatoryPreorder': mandatoryPreorder,
    'status': status,
  };

  factory MemberCategory.fromJson(Map<String, dynamic> json) => MemberCategory(
    id: json['id']?.toString() ?? '',
    code: json['code']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    canteenIds: _stringList(json['canteenIds']),
    serviceProviderIds:
        json['serviceProviderIds'] == null
            ? null
            : _stringList(json['serviceProviderIds']),
    coFundingType: json['coFundingType']?.toString() ?? '',
    coFundingValue: _doubleValue(json['coFundingValue']),
    mealsPerServing: _intValue(json['mealsPerServing']),
    allowIndividualPreference: _boolValue(json['allowIndividualPreference']),
    mandatoryPreorder: _boolValue(json['mandatoryPreorder']),
    status: _boolValue(json['status']),
  );

  static List<MemberCategory> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map((item) => MemberCategory.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  MemberCategory copyWith({
    String? id,
    String? code,
    String? name,
    List<String>? canteenIds,
    List<String>? serviceProviderIds,
    String? coFundingType,
    double? coFundingValue,
    int? mealsPerServing,
    bool? allowIndividualPreference,
    bool? mandatoryPreorder,
    bool? status,
  }) => MemberCategory(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    canteenIds: canteenIds ?? this.canteenIds,
    serviceProviderIds: serviceProviderIds ?? this.serviceProviderIds,
    coFundingType: coFundingType ?? this.coFundingType,
    coFundingValue: coFundingValue ?? this.coFundingValue,
    mealsPerServing: mealsPerServing ?? this.mealsPerServing,
    allowIndividualPreference:
        allowIndividualPreference ?? this.allowIndividualPreference,
    mandatoryPreorder: mandatoryPreorder ?? this.mandatoryPreorder,
    status: status ?? this.status,
  );
}

class UserCategoriesApiResponse {
  final List<MemberCategory> items;
  final bool empty;
  final int currentPage;
  final int resultsPerPage;
  final int totalPages;
  final int totalResults;

  const UserCategoriesApiResponse({
    required this.items,
    required this.empty,
    required this.currentPage,
    required this.resultsPerPage,
    required this.totalPages,
    required this.totalResults,
  });

  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
    'empty': empty,
    'currentPage': currentPage,
    'resultsPerPage': resultsPerPage,
    'totalPages': totalPages,
    'totalResults': totalResults,
  };

  factory UserCategoriesApiResponse.fromJson(Map<String, dynamic> json) =>
      UserCategoriesApiResponse(
        items:
            json['items'] is List
                ? MemberCategory.fromJsonList(json['items'])
                : <MemberCategory>[],
        empty: _boolValue(json['empty']),
        currentPage: _intValue(json['currentPage']),
        resultsPerPage: _intValue(json['resultsPerPage']),
        totalPages: _intValue(json['totalPages']),
        totalResults: _intValue(json['totalResults']),
      );

  static List<UserCategoriesApiResponse> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => UserCategoriesApiResponse.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

  UserCategoriesApiResponse copyWith({
    List<MemberCategory>? items,
    bool? empty,
    int? currentPage,
    int? resultsPerPage,
    int? totalPages,
    int? totalResults,
  }) => UserCategoriesApiResponse(
    items: items ?? this.items,
    empty: empty ?? this.empty,
    currentPage: currentPage ?? this.currentPage,
    resultsPerPage: resultsPerPage ?? this.resultsPerPage,
    totalPages: totalPages ?? this.totalPages,
    totalResults: totalResults ?? this.totalResults,
  );
}

List<String> _stringList(dynamic value) =>
    value is List
        ? value
            .where((item) => item != null)
            .map((item) => item.toString())
            .toList()
        : <String>[];

int _intValue(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

double _doubleValue(dynamic value) =>
    value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0;

bool _boolValue(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}

final List<MemberCategory> sampleUserCategories = [
  MemberCategory(
    id: 'user_category_1',
    code: 'user_category_1',
    name: 'User Category 1',
    canteenIds: ['canteen_001', 'canteen_002'],
    serviceProviderIds: ['service_provider_1', 'service_provider_2'],
    coFundingType: 'co_funding_type_1',
    coFundingValue: 100.0,
    mealsPerServing: 5,
    allowIndividualPreference: true,
    mandatoryPreorder: true,
    status: true,
  ),
  MemberCategory(
    id: 'user_category_2',
    code: 'user_category_2',
    name: 'User Category 2',
    canteenIds: ['canteen_001', 'canteen_002'],
    serviceProviderIds: ['service_provider_1',],
    coFundingType: 'co_funding_type_2',
    coFundingValue: 200.0,
    mealsPerServing: 2,
    allowIndividualPreference: false,
    mandatoryPreorder: false,
    status: true,
  ),

];
