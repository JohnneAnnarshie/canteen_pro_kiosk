class ServedMeal {
  final String id;
  final String orderId;
  final String serverId;
  final int servedDateTime;

  const ServedMeal({
    required this.id,
    required this.orderId,
    required this.serverId,
    required this.servedDateTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': orderId,
    'serverId': serverId,
    'servedDateTime': servedDateTime,
  };

  factory ServedMeal.fromJson(Map<String, dynamic> json) => ServedMeal(
    id: json['id']?.toString() ?? '',
    orderId: json['orderId']?.toString() ?? '',
    serverId: json['serverId']?.toString() ?? '',
    servedDateTime: _intValue(json['servedDateTime']),
  );

  static List<ServedMeal> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map((item) => ServedMeal.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  ServedMeal copyWith({
    String? id,
    String? orderId,
    String? serverId,
    int? servedDateTime,
  }) => ServedMeal(
    id: id ?? this.id,
    orderId: orderId ?? this.orderId,
    serverId: serverId ?? this.serverId,
    servedDateTime: servedDateTime ?? this.servedDateTime,
  );
}

int _intValue(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
