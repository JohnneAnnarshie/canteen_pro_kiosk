class Menu {
  final String id;
  final String name;
  final String accesses;
  final List<String> menus;
  final String navicationPath;
  final String iconPath;
  final bool status;
  final String orderKey;

  const Menu({
    required this.id,
    required this.name,
    required this.accesses,
    required this.menus,
    required this.navicationPath,
    required this.iconPath,
    required this.status,
    required this.orderKey,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'accesses': accesses,
    'menus': menus,
    'navicationPath': navicationPath,
    'iconPath': iconPath,
    'status': status,
    'orderKey': orderKey,
  };

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    accesses: json['accesses']?.toString() ?? '',
    menus: _stringList(json['menus']),
    navicationPath: json['navicationPath']?.toString() ?? '',
    iconPath: json['iconPath']?.toString() ?? '',
    status: _boolValue(json['status']),
    orderKey: json['orderKey']?.toString() ?? '',
  );

  static List<Menu> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map((item) => Menu.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  Menu copyWith({
    String? id,
    String? name,
    String? accesses,
    List<String>? menus,
    String? navicationPath,
    String? iconPath,
    bool? status,
    String? orderKey,
  }) => Menu(
    id: id ?? this.id,
    name: name ?? this.name,
    accesses: accesses ?? this.accesses,
    menus: menus ?? this.menus,
    navicationPath: navicationPath ?? this.navicationPath,
    iconPath: iconPath ?? this.iconPath,
    status: status ?? this.status,
    orderKey: orderKey ?? this.orderKey,
  );
}

List<String> _stringList(dynamic value) =>
    value is List
        ? value
            .where((item) => item != null)
            .map((item) => item.toString())
            .toList()
        : <String>[];

bool _boolValue(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}
