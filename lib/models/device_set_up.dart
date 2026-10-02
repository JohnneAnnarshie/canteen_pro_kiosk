class DeviceSetUp {
  final String deviceSetupId;
  final String? deviceName;
  final String? code;
  final String serialNumber;
  final String brand;
  final String model;
  final String deviceType;
  final bool? status;

  const DeviceSetUp({
    required this.deviceSetupId,
    this.deviceName,
    this.code,
    required this.serialNumber,
    required this.brand,
    required this.model,
    required this.deviceType,
    this.status,
  });

  Map<String, dynamic> toJson() => {
    'deviceSetupId': deviceSetupId,
    'deviceName': deviceName,
    'code': code,
    'serialNumber': serialNumber,
    'brand': brand,
    'model': model,
    'deviceType': deviceType,
    'status': status,
  };

  factory DeviceSetUp.fromJson(Map<String, dynamic> json) => DeviceSetUp(
    deviceSetupId: json['deviceSetupId']?.toString() ?? '',
    deviceName: json['deviceName']?.toString(),
    code: json['code']?.toString(),
    serialNumber: json['serialNumber']?.toString() ?? '',
    brand: json['brand']?.toString() ?? '',
    model: json['model']?.toString() ?? '',
    deviceType: json['deviceType']?.toString() ?? '',
    status: _boolNullableValue(json['status']),
  );

  static List<DeviceSetUp> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map((item) => DeviceSetUp.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  DeviceSetUp copyWith({
    String? deviceSetupId,
    String? deviceName,
    String? code,
    String? serialNumber,
    String? brand,
    String? model,
    String? deviceType,
    bool? status,
  }) => DeviceSetUp(
    deviceSetupId: deviceSetupId ?? this.deviceSetupId,
    deviceName: deviceName ?? this.deviceName,
    code: code ?? this.code,
    serialNumber: serialNumber ?? this.serialNumber,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    deviceType: deviceType ?? this.deviceType,
    status: status ?? this.status,
  );

  Set<String> get toStringSet => {
    deviceSetupId,
    deviceName ?? '',
    code ?? '',
    serialNumber,
    brand,
    model,
    deviceType,
    status.toString(),
  };

  static DeviceSetUp fromStringSet(Set<String> values) {
    final list = values.toList();
    String? valueAt(int index) => index < list.length ? list[index] : null;

    return DeviceSetUp(
      deviceSetupId: valueAt(0) ?? '',
      deviceName: valueAt(1),
      code: valueAt(2),
      serialNumber: valueAt(3) ?? '',
      brand: valueAt(4) ?? '',
      model: valueAt(5) ?? '',
      deviceType: valueAt(6) ?? '',
      status: valueAt(7)?.toLowerCase() == 'true',
    );
  }
}

extension DeviceSetUpStringSetExtensions on Set<String> {
  DeviceSetUp get toDeviceSetUp => DeviceSetUp.fromStringSet(this);
}

class NetworkPhysicalDevice {
  final String id;
  final String deviceSetupId;
  final String? deviceName;
  final String? code;
  final String serialNumber;
  final String brand;
  final String model;
  final String? deviceType;
  final int status;

  const NetworkPhysicalDevice({
    required this.id,
    required this.deviceSetupId,
    this.deviceName,
    this.code,
    required this.serialNumber,
    required this.brand,
    required this.model,
    this.deviceType,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceSetupId': deviceSetupId,
    'deviceName': deviceName,
    'code': code,
    'serialNumber': serialNumber,
    'brand': brand,
    'model': model,
    'deviceType': deviceType,
    'status': status,
  };

  factory NetworkPhysicalDevice.fromJson(Map<String, dynamic> json) =>
      NetworkPhysicalDevice(
        id: json['id']?.toString() ?? '',
        deviceSetupId: json['deviceSetupId']?.toString() ?? '',
        deviceName: json['deviceName']?.toString(),
        code: json['code']?.toString(),
        serialNumber: json['serialNumber']?.toString() ?? '',
        brand: json['brand']?.toString() ?? '',
        model: json['model']?.toString() ?? '',
        deviceType: json['deviceType']?.toString(),
        status: _intValue(json['status']),
      );

  static List<NetworkPhysicalDevice> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) =>
                NetworkPhysicalDevice.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  NetworkPhysicalDevice copyWith({
    String? id,
    String? deviceSetupId,
    String? deviceName,
    String? code,
    String? serialNumber,
    String? brand,
    String? model,
    String? deviceType,
    int? status,
  }) => NetworkPhysicalDevice(
    id: id ?? this.id,
    deviceSetupId: deviceSetupId ?? this.deviceSetupId,
    deviceName: deviceName ?? this.deviceName,
    code: code ?? this.code,
    serialNumber: serialNumber ?? this.serialNumber,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    deviceType: deviceType ?? this.deviceType,
    status: status ?? this.status,
  );
}

class NetworkDeviceSetUp {
  final String id;
  final String name;
  final String code;
  final String deviceType;
  final String assignedStationId;
  final bool status;

  const NetworkDeviceSetUp({
    required this.id,
    required this.name,
    required this.code,
    required this.deviceType,
    required this.assignedStationId,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'deviceType': deviceType,
    'assignedStationId': assignedStationId,
    'status': status,
  };

  factory NetworkDeviceSetUp.fromJson(Map<String, dynamic> json) =>
      NetworkDeviceSetUp(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        deviceType: json['deviceType']?.toString() ?? '',
        assignedStationId: json['assignedStationId']?.toString() ?? '',
        status: _boolValue(json['status']),
      );

  static List<NetworkDeviceSetUp> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) =>
                NetworkDeviceSetUp.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  NetworkDeviceSetUp copyWith({
    String? id,
    String? name,
    String? code,
    String? deviceType,
    String? assignedStationId,
    bool? status,
  }) => NetworkDeviceSetUp(
    id: id ?? this.id,
    name: name ?? this.name,
    code: code ?? this.code,
    deviceType: deviceType ?? this.deviceType,
    assignedStationId: assignedStationId ?? this.assignedStationId,
    status: status ?? this.status,
  );
}

class NetworkDeviceSetUpApiResponse {
  final List<NetworkDeviceSetUp> items;
  final bool empty;
  final int currentPage;
  final int resultsPerPage;
  final int totalPages;
  final int totalResults;

  const NetworkDeviceSetUpApiResponse({
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

  factory NetworkDeviceSetUpApiResponse.fromJson(Map<String, dynamic> json) =>
      NetworkDeviceSetUpApiResponse(
        items:
            json['items'] is List
                ? NetworkDeviceSetUp.fromJsonList(json['items'])
                : <NetworkDeviceSetUp>[],
        empty: _boolValue(json['empty']),
        currentPage: _intValue(json['currentPage']),
        resultsPerPage: _intValue(json['resultsPerPage']),
        totalPages: _intValue(json['totalPages']),
        totalResults: _intValue(json['totalResults']),
      );

  static List<NetworkDeviceSetUpApiResponse> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => NetworkDeviceSetUpApiResponse.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

  NetworkDeviceSetUpApiResponse copyWith({
    List<NetworkDeviceSetUp>? items,
    bool? empty,
    int? currentPage,
    int? resultsPerPage,
    int? totalPages,
    int? totalResults,
  }) => NetworkDeviceSetUpApiResponse(
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

bool? _boolNullableValue(dynamic value) {
  if (value == null) return null;
  return _boolValue(value);
}
