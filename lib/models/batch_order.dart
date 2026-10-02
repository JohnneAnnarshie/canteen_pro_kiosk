class BatchOrder {
  final String? id;
  final String employeeId;
  final String mealId;
  final int quantity;
  final String billingEntityId;
  final String periodId;
  final String locationId;
  final String mealRosterId;
  final String availableDate;

  const BatchOrder({
    this.id,
    required this.employeeId,
    required this.mealId,
    required this.quantity,
    required this.billingEntityId,
    required this.periodId,
    required this.locationId,
    required this.mealRosterId,
    required this.availableDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'employeeId': employeeId,
    'mealId': mealId,
    'quantity': quantity,
    'billingEntityId': billingEntityId,
    'periodId': periodId,
    'locationId': locationId,
    'mealRosterId': mealRosterId,
    'availableDate': availableDate,
  };

  factory BatchOrder.fromJson(Map<String, dynamic> json) => BatchOrder(
    id: json['id']?.toString(),
    employeeId: json['employeeId']?.toString() ?? '',
    mealId: json['mealId']?.toString() ?? '',
    quantity: _intValue(json['quantity']),
    billingEntityId: json['billingEntityId']?.toString() ?? '',
    periodId: json['periodId']?.toString() ?? '',
    locationId: json['locationId']?.toString() ?? '',
    mealRosterId: json['mealRosterId']?.toString() ?? '',
    availableDate: json['availableDate']?.toString() ?? '',
  );

  static List<BatchOrder> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map((item) => BatchOrder.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  BatchOrder copyWith({
    String? id,
    String? employeeId,
    String? mealId,
    int? quantity,
    String? billingEntityId,
    String? periodId,
    String? locationId,
    String? mealRosterId,
    String? availableDate,
  }) => BatchOrder(
    id: id ?? this.id,
    employeeId: employeeId ?? this.employeeId,
    mealId: mealId ?? this.mealId,
    quantity: quantity ?? this.quantity,
    billingEntityId: billingEntityId ?? this.billingEntityId,
    periodId: periodId ?? this.periodId,
    locationId: locationId ?? this.locationId,
    mealRosterId: mealRosterId ?? this.mealRosterId,
    availableDate: availableDate ?? this.availableDate,
  );
}

class BatchOrderItem {
  final String employeeId;
  final String mealId;
  final int quantity;
  final String billingEntityId;
  final String periodId;
  final String locationId;
  final String mealRosterId;
  final String availableDate;

  const BatchOrderItem({
    required this.employeeId,
    required this.mealId,
    required this.quantity,
    required this.billingEntityId,
    required this.periodId,
    required this.locationId,
    required this.mealRosterId,
    required this.availableDate,
  });

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'mealId': mealId,
    'quantity': quantity,
    'billingEntityId': billingEntityId,
    'periodId': periodId,
    'locationId': locationId,
    'mealRosterId': mealRosterId,
    'availableDate': availableDate,
  };

  factory BatchOrderItem.fromJson(Map<String, dynamic> json) => BatchOrderItem(
    employeeId: json['employeeId']?.toString() ?? '',
    mealId: json['mealId']?.toString() ?? '',
    quantity: _intValue(json['quantity']),
    billingEntityId: json['billingEntityId']?.toString() ?? '',
    periodId: json['periodId']?.toString() ?? '',
    locationId: json['locationId']?.toString() ?? '',
    mealRosterId: json['mealRosterId']?.toString() ?? '',
    availableDate: json['availableDate']?.toString() ?? '',
  );

  static List<BatchOrderItem> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => BatchOrderItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  BatchOrderItem copyWith({
    String? employeeId,
    String? mealId,
    int? quantity,
    String? billingEntityId,
    String? periodId,
    String? locationId,
    String? mealRosterId,
    String? availableDate,
  }) => BatchOrderItem(
    employeeId: employeeId ?? this.employeeId,
    mealId: mealId ?? this.mealId,
    quantity: quantity ?? this.quantity,
    billingEntityId: billingEntityId ?? this.billingEntityId,
    periodId: periodId ?? this.periodId,
    locationId: locationId ?? this.locationId,
    mealRosterId: mealRosterId ?? this.mealRosterId,
    availableDate: availableDate ?? this.availableDate,
  );
}

class BatchOrderDto {
  final List<BatchOrderItem> badgeFoods;

  const BatchOrderDto({required this.badgeFoods});

  Map<String, dynamic> toJson() => {
    'badgeFoods': badgeFoods.map((item) => item.toJson()).toList(),
  };

  factory BatchOrderDto.fromJson(Map<String, dynamic> json) => BatchOrderDto(
    badgeFoods:
        json['badgeFoods'] is List
            ? BatchOrderItem.fromJsonList(json['badgeFoods'])
            : <BatchOrderItem>[],
  );

  static List<BatchOrderDto> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => BatchOrderDto.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  BatchOrderDto copyWith({List<BatchOrderItem>? badgeFoods}) =>
      BatchOrderDto(badgeFoods: badgeFoods ?? this.badgeFoods);
}

int _intValue(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

typedef BatchOrderDTO = BatchOrderDto;

extension BatchOrderExtensions on BatchOrder {
  BatchOrderItem toBatchOrderItem() => BatchOrderItem(
    employeeId: employeeId,
    mealId: mealId,
    quantity: quantity,
    billingEntityId: billingEntityId,
    periodId: periodId,
    locationId: locationId,
    mealRosterId: mealRosterId,
    availableDate: availableDate,
  );
}
