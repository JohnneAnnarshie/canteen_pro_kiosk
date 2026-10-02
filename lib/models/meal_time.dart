class MealTime {
  final String id;
  final String code;
  final String name;
  final String startTime;
  final String endTime;
  final String? description;
  final bool status;

  const MealTime({
    required this.id,
    required this.code,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.description,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'startTime': startTime,
    'endTime': endTime,
    'description': description,
    'status': status,
  };

  factory MealTime.fromJson(Map<String, dynamic> json) => MealTime(
    id: json['id']?.toString() ?? '',
    code: json['code']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    startTime: json['startTime']?.toString() ?? '',
    endTime: json['endTime']?.toString() ?? '',
    description: json['description']?.toString(),
    status: _boolValue(json['status']),
  );

  static List<MealTime> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map((item) => MealTime.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  MealTime copyWith({
    String? id,
    String? code,
    String? name,
    String? startTime,
    String? endTime,
    String? description,
    bool? status,
  }) => MealTime(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    description: description ?? this.description,
    status: status ?? this.status,
  );
}

class MealTimeApiResponse {
  final List<MealTime> items;
  final bool empty;
  final int currentPage;
  final int resultsPerPage;
  final int totalPages;
  final int totalResults;

  const MealTimeApiResponse({
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

  factory MealTimeApiResponse.fromJson(Map<String, dynamic> json) =>
      MealTimeApiResponse(
        items:
            json['items'] is List
                ? MealTime.fromJsonList(json['items'])
                : <MealTime>[],
        empty: _boolValue(json['empty']),
        currentPage: _intValue(json['currentPage']),
        resultsPerPage: _intValue(json['resultsPerPage']),
        totalPages: _intValue(json['totalPages']),
        totalResults: _intValue(json['totalResults']),
      );

  static List<MealTimeApiResponse> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) =>
                MealTimeApiResponse.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  MealTimeApiResponse copyWith({
    List<MealTime>? items,
    bool? empty,
    int? currentPage,
    int? resultsPerPage,
    int? totalPages,
    int? totalResults,
  }) => MealTimeApiResponse(
    items: items ?? this.items,
    empty: empty ?? this.empty,
    currentPage: currentPage ?? this.currentPage,
    resultsPerPage: resultsPerPage ?? this.resultsPerPage,
    totalPages: totalPages ?? this.totalPages,
    totalResults: totalResults ?? this.totalResults,
  );
}

class ActiveMealTime {
  final String id;
  final String code;
  final String name;

  const ActiveMealTime({
    required this.id,
    required this.code,
    required this.name,
  });

  Map<String, dynamic> toJson() => {'id': id, 'code': code, 'name': name};

  factory ActiveMealTime.fromJson(Map<String, dynamic> json) => ActiveMealTime(
    id: json['id']?.toString() ?? '',
    code: json['code']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
  );

  static List<ActiveMealTime> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => ActiveMealTime.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  ActiveMealTime copyWith({String? id, String? code, String? name}) =>
      ActiveMealTime(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
      );
}

int _intValue(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

bool _boolValue(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}

extension MealTimeExtensions on MealTime {
  ActiveMealTime toActiveMealTime() =>
      ActiveMealTime(id: id, code: code, name: name);
}

final List<ActiveMealTime> sampleActiveMealTimes = [
  ActiveMealTime(id: 'breakfast_1', code: 'breakfast', name: 'Breakfast'),
  ActiveMealTime(id: 'lunch_2', code: 'lunch', name: 'Lunch'),
  ActiveMealTime(id: 'dinner_3', code: 'dinner', name: 'Dinner'),
];
