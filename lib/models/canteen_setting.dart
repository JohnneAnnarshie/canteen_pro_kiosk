class CanteenSetting {
  final String id;
  final String code;
  final String name;
  final String? description;
  final bool status;

  const CanteenSetting({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.status,
  });

  Map<String, dynamic> toJson() => toMap();

  factory CanteenSetting.fromJson(Map<String, dynamic> json) => CanteenSetting(
    id: json['id']?.toString() ?? '',
    code: json['code']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    description: json['description']?.toString(),
    status: _boolValue(json['status']),
  );

  static List<CanteenSetting> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => CanteenSetting.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  static CanteenSetting fromMap(Map<String, dynamic> map) {
    return CanteenSetting(
      id: map['id'],
      code: map['code'],
      name: map['name'],
      description: map['description'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'status': status,
    };
  }

  static List<CanteenSetting> fromMapList(List<Map<String, dynamic>> list) {
    return list.map((map) => fromMap(map)).toList();
  }

  CanteenSetting copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    bool? status,
  }) => CanteenSetting(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    description: description ?? this.description,
    status: status ?? this.status,
  );
}

class CanteenSettingApiResponse {
  final List<CanteenSetting> items;
  final bool empty;
  final int currentPage;
  final int resultsPerPage;
  final int totalPages;
  final int totalResults;

  const CanteenSettingApiResponse({
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

  factory CanteenSettingApiResponse.fromJson(Map<String, dynamic> json) =>
      CanteenSettingApiResponse(
        items:
            json['items'] is List
                ? CanteenSetting.fromJsonList(json['items'])
                : <CanteenSetting>[],
        empty: _boolValue(json['empty']),
        currentPage: _intValue(json['currentPage']),
        resultsPerPage: _intValue(json['resultsPerPage']),
        totalPages: _intValue(json['totalPages']),
        totalResults: _intValue(json['totalResults']),
      );

  static List<CanteenSettingApiResponse> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => CanteenSettingApiResponse.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

  CanteenSettingApiResponse copyWith({
    List<CanteenSetting>? items,
    bool? empty,
    int? currentPage,
    int? resultsPerPage,
    int? totalPages,
    int? totalResults,
  }) => CanteenSettingApiResponse(
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

bool _boolValue(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}

final List<CanteenSetting> sampleCanteenSettings = const [
  CanteenSetting(id: 'canteen_001', code: 'C001', name: 'Main Canteen', status: true),
  CanteenSetting(id: 'canteen_002', code: 'C002', name: 'Second Canteen', status: true),
  CanteenSetting(id: 'canteen_003', code: 'C003', name: 'Third Canteen', status: true),
];
