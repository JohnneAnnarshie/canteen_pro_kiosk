import 'active_meal.dart';

class MealItem {
  final String id;
  final String code;
  final String mealName;
  final String serviceProviderId;
  final double price;
  final String? description;
  final bool status;

  const MealItem({
    required this.id,
    required this.code,
    required this.mealName,
    required this.serviceProviderId,
    required this.price,
    this.description,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'mealName': mealName,
    'seviceProviderId': serviceProviderId,
    'price': price,
    'description': description,
    'status': status,
  };

  factory MealItem.fromJson(Map<String, dynamic> json) => MealItem(
    id: json['id']?.toString() ?? '',
    code: json['code']?.toString() ?? '',
    mealName: json['mealName']?.toString() ?? '',
    serviceProviderId: json['seviceProviderId']?.toString() ?? '',
    price: _doubleValue(json['price']),
    description: json['description']?.toString(),
    status: _boolValue(json['status']),
  );

  static List<MealItem> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map((item) => MealItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  MealItem copyWith({
    String? id,
    String? code,
    String? mealName,
    String? serviceProviderId,
    double? price,
    String? description,
    bool? status,
  }) => MealItem(
    id: id ?? this.id,
    code: code ?? this.code,
    mealName: mealName ?? this.mealName,
    serviceProviderId: serviceProviderId ?? this.serviceProviderId,
    price: price ?? this.price,
    description: description ?? this.description,
    status: status ?? this.status,
  );
}

class Meal {
  final String id;
  final String code;
  final String mealName;
  final String serviceProviderId;
  final double? price;
  final String? description;
  final bool status;

  const Meal({
    required this.id,
    required this.code,
    required this.mealName,
    required this.serviceProviderId,
    this.price,
    this.description,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'mealName': mealName,
    'seviceProviderId': serviceProviderId,
    'price': price,
    'description': description,
    'status': status,
  };

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
    id: json['id']?.toString() ?? '',
    code: json['code']?.toString() ?? '',
    mealName: json['mealName']?.toString() ?? '',
    serviceProviderId: json['seviceProviderId']?.toString() ?? '',
    price: _nullableDoubleValue(json['price']),
    description: json['description']?.toString(),
    status: _boolValue(json['status']),
  );

  static List<Meal> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map((item) => Meal.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  Meal copyWith({
    String? id,
    String? code,
    String? mealName,
    String? serviceProviderId,
    double? price,
    String? description,
    bool? status,
  }) => Meal(
    id: id ?? this.id,
    code: code ?? this.code,
    mealName: mealName ?? this.mealName,
    serviceProviderId: serviceProviderId ?? this.serviceProviderId,
    price: price ?? this.price,
    description: description ?? this.description,
    status: status ?? this.status,
  );
}

class MealApiResponse {
  final List<MealItem> items;
  final bool empty;
  final int currentPage;
  final int resultsPerPage;
  final int totalPages;
  final int totalResults;

  const MealApiResponse({
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

  factory MealApiResponse.fromJson(Map<String, dynamic> json) =>
      MealApiResponse(
        items:
            json['items'] is List
                ? MealItem.fromJsonList(json['items'])
                : <MealItem>[],
        empty: _boolValue(json['empty']),
        currentPage: _intValue(json['currentPage']),
        resultsPerPage: _intValue(json['resultsPerPage']),
        totalPages: _intValue(json['totalPages']),
        totalResults: _intValue(json['totalResults']),
      );

  static List<MealApiResponse> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => MealApiResponse.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  MealApiResponse copyWith({
    List<MealItem>? items,
    bool? empty,
    int? currentPage,
    int? resultsPerPage,
    int? totalPages,
    int? totalResults,
  }) => MealApiResponse(
    items: items ?? this.items,
    empty: empty ?? this.empty,
    currentPage: currentPage ?? this.currentPage,
    resultsPerPage: resultsPerPage ?? this.resultsPerPage,
    totalPages: totalPages ?? this.totalPages,
    totalResults: totalResults ?? this.totalResults,
  );
}

int _intValue(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

double _doubleValue(dynamic value) =>
    value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0;

double? _nullableDoubleValue(dynamic value) =>
    value == null
        ? null
        : value is num
        ? value.toDouble()
        : double.tryParse(value.toString());

bool _boolValue(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}

extension MealItemExtensions on MealItem {
  Meal toMeal() => Meal(
    id: id,
    code: code,
    mealName: mealName,
    serviceProviderId: serviceProviderId,
    price: price,
    description: description,
    status: status,
  );

  ActiveMeal toActiveMeal() =>
      ActiveMeal(id: id, name: mealName, description: description);
}
