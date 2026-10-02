class Order {
  final String? mealRosterId;
  final String? orderId;
  final String? employeeId;
  final double? totalPrice;
  final double? totalSubsidyPrice;
  final String? userCategoryId;
  final int quantity;
  final String billingEntityId;
  final String? periodId;
  final String? locationId;
  final String availableDate;
  final String mealId;
  final String? username;
  final String? mealName;
  final String? serviceProvider;
  final String? location;
  final String? periodName;

  const Order({
    this.mealRosterId,
    this.orderId,
    this.employeeId,
    this.totalPrice,
    this.totalSubsidyPrice,
    this.userCategoryId,
    required this.quantity,
    required this.billingEntityId,
    this.periodId,
    this.locationId,
    required this.availableDate,
    required this.mealId,
    this.username,
    this.mealName,
    this.serviceProvider,
    this.location,
    this.periodName,
  });

  Map<String, dynamic> toJson() => {
    'mealRosterId': mealRosterId,
    'orderId': orderId,
    'employeeId': employeeId,
    'totalPrice': totalPrice,
    'totalSubsidyPrice': totalSubsidyPrice,
    'userCategoryId': userCategoryId,
    'quantity': quantity,
    'billingEntityId': billingEntityId,
    'periodId': periodId,
    'locationId': locationId,
    'availableDate': availableDate,
    'mealId': mealId,
    'username': username,
    'mealName': mealName,
    'serviceProvider': serviceProvider,
    'location': location,
    'periodName': periodName,
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    mealRosterId: json['mealRosterId']?.toString(),
    orderId: json['orderId']?.toString(),
    employeeId: json['employeeId']?.toString(),
    totalPrice: _nullableDoubleValue(json['totalPrice']),
    totalSubsidyPrice: _nullableDoubleValue(json['totalSubsidyPrice']),
    userCategoryId: json['userCategoryId']?.toString(),
    quantity: _intValue(json['quantity']),
    billingEntityId: json['billingEntityId']?.toString() ?? '',
    periodId: json['periodId']?.toString(),
    locationId: json['locationId']?.toString(),
    availableDate: json['availableDate']?.toString() ?? '',
    mealId: json['mealId']?.toString() ?? '',
    username: json['username']?.toString(),
    mealName: json['mealName']?.toString(),
    serviceProvider: json['serviceProvider']?.toString(),
    location: json['location']?.toString(),
    periodName: json['periodName']?.toString(),
  );

  static List<Order> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map((item) => Order.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  Order copyWith({
    String? mealRosterId,
    String? orderId,
    String? employeeId,
    double? totalPrice,
    double? totalSubsidyPrice,
    String? userCategoryId,
    int? quantity,
    String? billingEntityId,
    String? periodId,
    String? locationId,
    String? availableDate,
    String? mealId,
    String? username,
    String? mealName,
    String? serviceProvider,
    String? location,
    String? periodName,
  }) => Order(
    mealRosterId: mealRosterId ?? this.mealRosterId,
    orderId: orderId ?? this.orderId,
    employeeId: employeeId ?? this.employeeId,
    totalPrice: totalPrice ?? this.totalPrice,
    totalSubsidyPrice: totalSubsidyPrice ?? this.totalSubsidyPrice,
    userCategoryId: userCategoryId ?? this.userCategoryId,
    quantity: quantity ?? this.quantity,
    billingEntityId: billingEntityId ?? this.billingEntityId,
    periodId: periodId ?? this.periodId,
    locationId: locationId ?? this.locationId,
    availableDate: availableDate ?? this.availableDate,
    mealId: mealId ?? this.mealId,
    username: username ?? this.username,
    mealName: mealName ?? this.mealName,
    serviceProvider: serviceProvider ?? this.serviceProvider,
    location: location ?? this.location,
    periodName: periodName ?? this.periodName,
  );
}

class OrderItemLocal {
  final int id;
  final String employeeId;
  final String mealId;
  final int quantity;
  final String billingEntityId;
  final String periodId;
  final String locationId;
  final String availableDate;
  final String? mealRosterId;

  const OrderItemLocal({
    this.id = 0,
    required this.employeeId,
    required this.mealId,
    required this.quantity,
    required this.billingEntityId,
    required this.periodId,
    required this.locationId,
    required this.availableDate,
    this.mealRosterId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'employeeId': employeeId,
    'mealId': mealId,
    'quantity': quantity,
    'billingEntityId': billingEntityId,
    'periodId': periodId,
    'locationId': locationId,
    'availableDate': availableDate,
    'mealRosterId': mealRosterId,
  };

  factory OrderItemLocal.fromJson(Map<String, dynamic> json) => OrderItemLocal(
    id: _intValue(json['id']),
    employeeId: json['employeeId']?.toString() ?? '',
    mealId: json['mealId']?.toString() ?? '',
    quantity: _intValue(json['quantity']),
    billingEntityId: json['billingEntityId']?.toString() ?? '',
    periodId: json['periodId']?.toString() ?? '',
    locationId: json['locationId']?.toString() ?? '',
    availableDate: json['availableDate']?.toString() ?? '',
    mealRosterId: json['mealRosterId']?.toString(),
  );

  static List<OrderItemLocal> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => OrderItemLocal.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  OrderItemLocal copyWith({
    int? id,
    String? employeeId,
    String? mealId,
    int? quantity,
    String? billingEntityId,
    String? periodId,
    String? locationId,
    String? availableDate,
    String? mealRosterId,
  }) => OrderItemLocal(
    id: id ?? this.id,
    employeeId: employeeId ?? this.employeeId,
    mealId: mealId ?? this.mealId,
    quantity: quantity ?? this.quantity,
    billingEntityId: billingEntityId ?? this.billingEntityId,
    periodId: periodId ?? this.periodId,
    locationId: locationId ?? this.locationId,
    availableDate: availableDate ?? this.availableDate,
    mealRosterId: mealRosterId ?? this.mealRosterId,
  );
}

class OrderItem {
  final String employeeId;
  final String mealId;
  final int quantity;
  final String billingEntityId;
  final String periodId;
  final String locationId;
  final String availableDate;
  final String? mealRosterId;

  const OrderItem({
    required this.employeeId,
    required this.mealId,
    required this.quantity,
    required this.billingEntityId,
    required this.periodId,
    required this.locationId,
    required this.availableDate,
    this.mealRosterId,
  });

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'mealId': mealId,
    'quantity': quantity,
    'billingEntityId': billingEntityId,
    'periodId': periodId,
    'locationId': locationId,
    'availableDate': availableDate,
    'mealRosterId': mealRosterId,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    employeeId: json['employeeId']?.toString() ?? '',
    mealId: json['mealId']?.toString() ?? '',
    quantity: _intValue(json['quantity']),
    billingEntityId: json['billingEntityId']?.toString() ?? '',
    periodId: json['periodId']?.toString() ?? '',
    locationId: json['locationId']?.toString() ?? '',
    availableDate: json['availableDate']?.toString() ?? '',
    mealRosterId: json['mealRosterId']?.toString(),
  );

  static List<OrderItem> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map((item) => OrderItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  OrderItem copyWith({
    String? employeeId,
    String? mealId,
    int? quantity,
    String? billingEntityId,
    String? periodId,
    String? locationId,
    String? availableDate,
    String? mealRosterId,
  }) => OrderItem(
    employeeId: employeeId ?? this.employeeId,
    mealId: mealId ?? this.mealId,
    quantity: quantity ?? this.quantity,
    billingEntityId: billingEntityId ?? this.billingEntityId,
    periodId: periodId ?? this.periodId,
    locationId: locationId ?? this.locationId,
    availableDate: availableDate ?? this.availableDate,
    mealRosterId: mealRosterId ?? this.mealRosterId,
  );
}

extension OrderExtensions on Order {
  OrderItem toOrderItem() => OrderItem(
    employeeId: employeeId ?? '',
    mealId: mealId,
    quantity: quantity,
    billingEntityId: billingEntityId,
    periodId: periodId ?? '',
    locationId: locationId ?? '',
    availableDate: availableDate,
    mealRosterId: mealRosterId,
  );

  OrderApiDto toOrderApiDto() => OrderApiDto(
    orders: [toOrderItem()],
  );
}

extension OrderItemExtensions on OrderItem {
  OrderItemLocal toLocal() => OrderItemLocal(
    employeeId: employeeId,
    mealId: mealId,
    quantity: quantity,
    billingEntityId: billingEntityId,
    periodId: periodId,
    locationId: locationId,
    availableDate: availableDate,
    mealRosterId: mealRosterId,
  );
}

extension OrderItemsExtensions on List<OrderItem> {
  OrderApiDto toOrderApiDto() => OrderApiDto(
    orders: this,
  );
}

extension OrderItemLocalExtensions on OrderItemLocal {
  OrderItem toOrderItem() => OrderItem(
    employeeId: employeeId,
    mealId: mealId,
    quantity: quantity,
    billingEntityId: billingEntityId,
    periodId: periodId,
    locationId: locationId,
    availableDate: availableDate,
    mealRosterId: mealRosterId,
  );
}

class OrderApiDto {
  final List<OrderItem> orders;

  const OrderApiDto({required this.orders});

  Map<String, dynamic> toJson() => {
    'orders': orders.map((item) => item.toJson()).toList(),
  };

  factory OrderApiDto.fromJson(Map<String, dynamic> json) => OrderApiDto(
    orders:
        json['orders'] is List
            ? OrderItem.fromJsonList(json['orders'])
            : <OrderItem>[],
  );

  static List<OrderApiDto> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map((item) => OrderApiDto.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  OrderApiDto copyWith({List<OrderItem>? orders}) =>
      OrderApiDto(orders: orders ?? this.orders);
}

typedef OrderApiDTO = OrderApiDto;

class ServeOrderDto {
  final String orderDetailId;
  final bool isServed;

  const ServeOrderDto({required this.orderDetailId, required this.isServed});

  Map<String, dynamic> toJson() => {
    'orderDetailId': orderDetailId,
    'isServed': isServed,
  };

  factory ServeOrderDto.fromJson(Map<String, dynamic> json) => ServeOrderDto(
    orderDetailId: json['orderDetailId']?.toString() ?? '',
    isServed: _boolValue(json['isServed']),
  );

  static List<ServeOrderDto> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => ServeOrderDto.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  ServeOrderDto copyWith({String? orderDetailId, bool? isServed}) =>
      ServeOrderDto(
        orderDetailId: orderDetailId ?? this.orderDetailId,
        isServed: isServed ?? this.isServed,
      );
}

typedef ServeOrderDTO = ServeOrderDto;

int _intValue(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

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
