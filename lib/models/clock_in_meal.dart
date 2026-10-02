class ClockInMealLocal {
  final int id;
  final String serviceProviderId;
  final String employeeId;
  final int quantity;
  final String billingEntityId;
  final String locationId;
  final String availableDate;
  final String mealTimeId;

  const ClockInMealLocal({
    this.id = 0,
    required this.serviceProviderId,
    required this.employeeId,
    required this.quantity,
    required this.billingEntityId,
    required this.locationId,
    required this.availableDate,
    required this.mealTimeId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'serviceProviderId': serviceProviderId,
    'employeeId': employeeId,
    'quantity': quantity,
    'billingEntityId': billingEntityId,
    'locationId': locationId,
    'availableDate': availableDate,
    'mealTimeId': mealTimeId,
  };

  factory ClockInMealLocal.fromJson(Map<String, dynamic> json) =>
      ClockInMealLocal(
        id: _intValue(json['id']),
        serviceProviderId: json['serviceProviderId']?.toString() ?? '',
        employeeId: json['employeeId']?.toString() ?? '',
        quantity: _intValue(json['quantity']),
        billingEntityId: json['billingEntityId']?.toString() ?? '',
        locationId: json['locationId']?.toString() ?? '',
        availableDate: json['availableDate']?.toString() ?? '',
        mealTimeId: json['mealTimeId']?.toString() ?? '',
      );

  static List<ClockInMealLocal> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) =>
                ClockInMealLocal.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  ClockInMealLocal copyWith({
    int? id,
    String? serviceProviderId,
    String? employeeId,
    int? quantity,
    String? billingEntityId,
    String? locationId,
    String? availableDate,
    String? mealTimeId,
  }) => ClockInMealLocal(
    id: id ?? this.id,
    serviceProviderId: serviceProviderId ?? this.serviceProviderId,
    employeeId: employeeId ?? this.employeeId,
    quantity: quantity ?? this.quantity,
    billingEntityId: billingEntityId ?? this.billingEntityId,
    locationId: locationId ?? this.locationId,
    availableDate: availableDate ?? this.availableDate,
    mealTimeId: mealTimeId ?? this.mealTimeId,
  );
}

class ClockInMealDto {
  final String serviceProviderId;
  final String employeeId;
  final int quantity;
  final String billingEntityId;
  final String locationId;
  final String availableDate;
  final String mealTimeId;

  const ClockInMealDto({
    required this.serviceProviderId,
    required this.employeeId,
    required this.quantity,
    required this.billingEntityId,
    required this.locationId,
    required this.availableDate,
    required this.mealTimeId,
  });

  Map<String, dynamic> toJson() => {
    'serviceProviderId': serviceProviderId,
    'employeeId': employeeId,
    'quantity': quantity,
    'billingEntityId': billingEntityId,
    'locationId': locationId,
    'availableDate': availableDate,
    'mealTimeId': mealTimeId,
  };

  factory ClockInMealDto.fromJson(Map<String, dynamic> json) => ClockInMealDto(
    serviceProviderId: json['serviceProviderId']?.toString() ?? '',
    employeeId: json['employeeId']?.toString() ?? '',
    quantity: _intValue(json['quantity']),
    billingEntityId: json['billingEntityId']?.toString() ?? '',
    locationId: json['locationId']?.toString() ?? '',
    availableDate: json['availableDate']?.toString() ?? '',
    mealTimeId: json['mealTimeId']?.toString() ?? '',
  );

  static List<ClockInMealDto> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => ClockInMealDto.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  ClockInMealDto copyWith({
    String? serviceProviderId,
    String? employeeId,
    int? quantity,
    String? billingEntityId,
    String? locationId,
    String? availableDate,
    String? mealTimeId,
  }) => ClockInMealDto(
    serviceProviderId: serviceProviderId ?? this.serviceProviderId,
    employeeId: employeeId ?? this.employeeId,
    quantity: quantity ?? this.quantity,
    billingEntityId: billingEntityId ?? this.billingEntityId,
    locationId: locationId ?? this.locationId,
    availableDate: availableDate ?? this.availableDate,
    mealTimeId: mealTimeId ?? this.mealTimeId,
  );
}

typedef ClockInMealDTO = ClockInMealDto;

extension ClockInMealLocalExtensions on ClockInMealLocal {
  ClockInMealDto toApiDto() => ClockInMealDto(
    serviceProviderId: serviceProviderId,
    employeeId: employeeId,
    quantity: quantity,
    billingEntityId: billingEntityId,
    locationId: locationId,
    availableDate: availableDate,
    mealTimeId: mealTimeId,
  );
}

extension ClockInMealDtoExtensions on ClockInMealDto {
  ClockInMealLocal toLocal() => ClockInMealLocal(
    serviceProviderId: serviceProviderId,
    employeeId: employeeId,
    quantity: quantity,
    billingEntityId: billingEntityId,
    locationId: locationId,
    availableDate: availableDate,
    mealTimeId: mealTimeId,
  );
}

int _intValue(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
