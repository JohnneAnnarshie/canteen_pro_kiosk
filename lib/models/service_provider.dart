class ServiceProvider {
  final String id;
  final String code;
  final String name;
  final String phone;
  final String email;
  final String address;
  final bool status;
  final String? contactPerson;
  final String? contactPhoneNumber;
  final String? contactEmail;

  const ServiceProvider({
    required this.id,
    required this.code,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.status,
    this.contactPerson,
    this.contactPhoneNumber,
    this.contactEmail,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'phone': phone,
    'email': email,
    'address': address,
    'status': status,
    'contactPerson': contactPerson,
    'contactPhoneNumber': contactPhoneNumber,
    'contactEmail': contactEmail,
  };

  factory ServiceProvider.fromJson(Map<String, dynamic> json) =>
      ServiceProvider(
        id: json['id']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        status: _boolValue(json['status']),
        contactPerson: json['contactPerson']?.toString(),
        contactPhoneNumber: json['contactPhoneNumber']?.toString(),
        contactEmail: json['contactEmail']?.toString(),
      );

  static List<ServiceProvider> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => ServiceProvider.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  ServiceProvider copyWith({
    String? id,
    String? code,
    String? name,
    String? phone,
    String? email,
    String? address,
    bool? status,
    String? contactPerson,
    String? contactPhoneNumber,
    String? contactEmail,
  }) => ServiceProvider(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    address: address ?? this.address,
    status: status ?? this.status,
    contactPerson: contactPerson ?? this.contactPerson,
    contactPhoneNumber: contactPhoneNumber ?? this.contactPhoneNumber,
    contactEmail: contactEmail ?? this.contactEmail,
  );
}

class ServiceProviderApiResponse {
  final List<ServiceProvider> items;
  final bool empty;
  final int currentPage;
  final int resultsPerPage;
  final int totalPages;
  final int totalResults;

  const ServiceProviderApiResponse({
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

  factory ServiceProviderApiResponse.fromJson(Map<String, dynamic> json) =>
      ServiceProviderApiResponse(
        items:
            json['items'] is List
                ? ServiceProvider.fromJsonList(json['items'])
                : <ServiceProvider>[],
        empty: _boolValue(json['empty']),
        currentPage: _intValue(json['currentPage']),
        resultsPerPage: _intValue(json['resultsPerPage']),
        totalPages: _intValue(json['totalPages']),
        totalResults: _intValue(json['totalResults']),
      );

  static List<ServiceProviderApiResponse> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => ServiceProviderApiResponse.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

  ServiceProviderApiResponse copyWith({
    List<ServiceProvider>? items,
    bool? empty,
    int? currentPage,
    int? resultsPerPage,
    int? totalPages,
    int? totalResults,
  }) => ServiceProviderApiResponse(
    items: items ?? this.items,
    empty: empty ?? this.empty,
    currentPage: currentPage ?? this.currentPage,
    resultsPerPage: resultsPerPage ?? this.resultsPerPage,
    totalPages: totalPages ?? this.totalPages,
    totalResults: totalResults ?? this.totalResults,
  );
}

class ActiveServiceProvider {
  final String id;
  final String name;
  final String? description;

  const ActiveServiceProvider({
    required this.id,
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };

  factory ActiveServiceProvider.fromJson(Map<String, dynamic> json) =>
      ActiveServiceProvider(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
      );

  static List<ActiveServiceProvider> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) =>
                ActiveServiceProvider.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  ActiveServiceProvider copyWith({
    String? id,
    String? name,
    String? description,
  }) => ActiveServiceProvider(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
  );
}

int _intValue(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

bool _boolValue(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}

final List<ActiveServiceProvider> sampleActiveServiceProviders = [
  ActiveServiceProvider(id: 'service_provider_1', name: 'Service Provider 1'),
  ActiveServiceProvider(id: 'service_provider_2', name: 'Service Provider 2'),
  ActiveServiceProvider(id: 'service_provider_3', name: 'Service Provider 3'),
];

final List<ServiceProvider> sampleServiceProviders = [
  ServiceProvider(
      id: 'service_provider_1',
      name: 'Service Provider 1',
      code: 'SP001', email: 'provider1@example.com', phone: '1234567890', address: '123 Main St', status: true),
  ServiceProvider(id: 'service_provider_2',
      name: 'Service Provider 2',
      code: 'SP002', email: 'provider2@example.com', phone: '9876543210', address: '456 Elm St', status: false),
  ServiceProvider(id: 'service_provider_3',
      name: 'Service Provider 3',
      code: 'SP003', email: 'provider3@example.com', phone: '5555555555', address: '789 Oak St', status: true),
];
