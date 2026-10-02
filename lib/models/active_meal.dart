class ActiveMeal {
  final String id;
  final String name;
  final String? description;

  const ActiveMeal({required this.id, required this.name, this.description});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };

  factory ActiveMeal.fromJson(Map<String, dynamic> json) => ActiveMeal(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    description: json['description']?.toString(),
  );

  static List<ActiveMeal> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map((item) => ActiveMeal.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  ActiveMeal copyWith({String? id, String? name, String? description}) =>
      ActiveMeal(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
      );
}

class SelectedActiveMeal {
  final String id;
  final ActiveMeal meal;
  final int quantity;
  final String provider;
  final String periodId;
  final String locationId;
  final String availableDate;
  final String mealType;
  final String? mealRosterId;

  const SelectedActiveMeal({
    required this.id,
    required this.meal,
    required this.quantity,
    required this.provider,
    required this.periodId,
    required this.locationId,
    required this.availableDate,
    required this.mealType,
    this.mealRosterId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'meal': meal.toJson(),
    'quantity': quantity,
    'provider': provider,
    'periodId': periodId,
    'locationId': locationId,
    'availableDate': availableDate,
    'mealType': mealType,
    'mealRosterId': mealRosterId,
  };

  factory SelectedActiveMeal.fromJson(Map<String, dynamic> json) =>
      SelectedActiveMeal(
        id: json['id']?.toString() ?? '',
        meal:
            json['meal'] is Map
                ? ActiveMeal.fromJson(Map<String, dynamic>.from(json['meal']))
                : const ActiveMeal(id: '', name: ''),
        quantity: _intValue(json['quantity']),
        provider: json['provider']?.toString() ?? '',
        periodId: json['periodId']?.toString() ?? '',
        locationId: json['locationId']?.toString() ?? '',
        availableDate: json['availableDate']?.toString() ?? '',
        mealType: json['mealType']?.toString() ?? '',
        mealRosterId: json['mealRosterId']?.toString(),
      );

  static List<SelectedActiveMeal> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) =>
                SelectedActiveMeal.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  SelectedActiveMeal copyWith({
    String? id,
    ActiveMeal? meal,
    int? quantity,
    String? provider,
    String? periodId,
    String? locationId,
    String? availableDate,
    String? mealType,
    String? mealRosterId,
  }) => SelectedActiveMeal(
    id: id ?? this.id,
    meal: meal ?? this.meal,
    quantity: quantity ?? this.quantity,
    provider: provider ?? this.provider,
    periodId: periodId ?? this.periodId,
    locationId: locationId ?? this.locationId,
    availableDate: availableDate ?? this.availableDate,
    mealType: mealType ?? this.mealType,
    mealRosterId: mealRosterId ?? this.mealRosterId,
  );
}

class ActiveMealsApiResponse {
  final List<ActiveMeal> items;
  final bool empty;
  final int currentPage;
  final int resultsPerPage;
  final int totalPages;
  final int totalResults;

  const ActiveMealsApiResponse({
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

  factory ActiveMealsApiResponse.fromJson(Map<String, dynamic> json) =>
      ActiveMealsApiResponse(
        items:
            json['items'] is List
                ? ActiveMeal.fromJsonList(json['items'])
                : <ActiveMeal>[],
        empty: _boolValue(json['empty']),
        currentPage: _intValue(json['currentPage']),
        resultsPerPage: _intValue(json['resultsPerPage']),
        totalPages: _intValue(json['totalPages']),
        totalResults: _intValue(json['totalResults']),
      );

  static List<ActiveMealsApiResponse> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => ActiveMealsApiResponse.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

  ActiveMealsApiResponse copyWith({
    List<ActiveMeal>? items,
    bool? empty,
    int? currentPage,
    int? resultsPerPage,
    int? totalPages,
    int? totalResults,
  }) => ActiveMealsApiResponse(
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

final List<ActiveMeal> sampleActiveMeals = const [
  ActiveMeal(id: 'meal_001', name: 'Jollof Rice with Grilled Chicked/Salad', description: 'Classic tomato rice with vegetables.'),
  ActiveMeal(id: 'meal_002', name: 'Banku and Tilapia', description: 'Fermented corn dough with grilled tilapia.'),
  ActiveMeal(id: 'meal_003', name: 'Waakye', description: 'Rice and beans with a savoury stew.'),
  ActiveMeal(id: 'meal_004', name: 'Fufu and Light Soup', description: 'Traditionally prepared fufu with light soup.'),
  ActiveMeal(id: 'meal_005', name: 'Chicken Curry', description: 'Tender chicken in rich curry sauce.'),
  ActiveMeal(id: 'meal_006', name: 'Red Red Stew', description: 'Black-eyed peas in a peppery tomato stew.'),
  ActiveMeal(id: 'meal_007', name: 'Rice and Stew', description: 'Plain rice served with beef or vegetable stew.'),
  ActiveMeal(id: 'meal_008', name: 'Ampesi', description: 'Boiled yam, plantain, and cocoyam with sauce.'),
  ActiveMeal(id: 'meal_009', name: 'Beans and Plantain', description: 'Stewed beans with ripe plantain.'),
  ActiveMeal(id: 'meal_010', name: 'Fried Rice', description: 'Vegetable fried rice with eggs and mixed vegetables.'),
];
