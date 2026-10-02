import 'package:canteen_pro/models/meal.dart';
import 'package:canteen_pro/models/meal_time.dart';
import 'package:canteen_pro/models/service_provider.dart';

import 'canteen_setting.dart';

class MasterMealRoster {
  final String id;
  final List<MasterRosterServiceProvider> serviceProviders;

  MasterMealRoster({
    required this.id,
    required this.serviceProviders,
  });

  factory MasterMealRoster.fromJson(Map<String, dynamic> json) {
    return MasterMealRoster(
      id: json['id'] as String,
      serviceProviders: (json['serviceProviders'] as List<dynamic>?)
          ?.map(
            (e) => MasterRosterServiceProvider.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList() ??
          [],
    );
  }

  MasterMealRoster copyWith({
    String? id,
    List<MasterRosterServiceProvider>? serviceProviders,
  }) {
    return MasterMealRoster(
      id: id ?? this.id,
      serviceProviders: serviceProviders ?? this.serviceProviders,
    );
  }
}

//      {
//         "serviceProviderId": "feb8d8f1-85d6-412e-a7dc-afd8fbb3d876",
//         "dates": [
//           {
//             "date": "2026-09-28T00:00:00",
//             "periods": [
//               {
//                 "periodId": "ff137bf4-d5f9-4dee-9f00-b31aaccd7fb1",
//                 "meals": [
//                   "978f48f8-18e6-4315-bc98-c5d5b37c210b",
//                   "758ffb7d-ef61-4da6-9e37-cb9c6bad1693",
//                   "83c31b71-09c4-430b-8256-d0bd4efbcfb9"
//                 ],
//                 "canteenIds": [
//                   "bbc72381-08b5-4caa-a465-7cbeff2f3362",
//                   "1a1af460-5a50-4dc2-abb6-8442e52f1376",
//                   "c893a5f1-c162-4c31-9e74-9eab5e9673ea",
//                   "ac08fbea-9c4e-4774-87fc-a873f94c1830"
//                 ]
//               }
//             ]
//           }
//         ]
//       },

class MasterRosterServiceProvider {
  ServiceProvider serviceProvider;
  final List<MasterRosterDates> dates;

  MasterRosterServiceProvider({
    required this.serviceProvider,
    required this.dates,
  });

  factory MasterRosterServiceProvider.fromJson(Map<String, dynamic> json) {
    return MasterRosterServiceProvider(
      serviceProvider: ServiceProvider.fromJson(json['serviceProvider'] as Map<String, dynamic>),
      dates: (json['dates'] as List<dynamic>?)
          ?.map(
            (e) => MasterRosterDates.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList() ??
          [],
    );
  }

  MasterRosterServiceProvider copyWith({
    ServiceProvider? serviceProvider,
    List<MasterRosterDates>? dates,
  }) {
    return MasterRosterServiceProvider(
      serviceProvider: serviceProvider ?? this.serviceProvider,
      dates: dates ?? this.dates,
    );
  }
}

class MasterRosterDates {
  final String date;
  final List<MasterRosterPeriods> periods;

  MasterRosterDates({
    required this.date,
    required this.periods,
  });

  factory MasterRosterDates.fromJson(Map<String, dynamic> json) {
    return MasterRosterDates(
      date: json['date'] as String,
      periods: (json['periods'] as List<dynamic>?)
          ?.map(
            (e) => MasterRosterPeriods.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList() ??
          [],
    );
  }

  MasterRosterDates copyWith({
    String? date,
    List<MasterRosterPeriods>? periods,
  }) {
    return MasterRosterDates(
      date: date ?? this.date,
      periods: periods ?? this.periods,
    );
  }
}

class MasterRosterPeriods {
  final MealTime period;
  final String orderStarTime;
  final String orderEndTime;
  final List<Meal> meals;
  final List<CanteenSetting> locations;

  MasterRosterPeriods({
    required this.period,
    required this.orderStarTime,
    required this.orderEndTime,
    required this.meals,
    required this.locations,
  });

  factory MasterRosterPeriods.fromJson(Map<String, dynamic> json) {
    return MasterRosterPeriods(
      period: MealTime.fromJson(
        json['period'] as Map<String, dynamic>,
      ),
      orderStarTime: json['orderStarTime'] as String,
      orderEndTime: json['orderEndTime'] as String,
      meals: (json['meals'] as List<dynamic>?)
          ?.map(
            (e) => Meal.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList() ??
          [],
      locations: (json['locations'] as List<dynamic>?)
          ?.map(
            (e) => CanteenSetting.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList() ??
          [],
    );
  }

  MasterRosterPeriods copyWith({
    MealTime? period,
    String? orderStarTime,
    String? orderEndTime,
    List<Meal>? meals,
    List<CanteenSetting>? locations,
  }) {
    return MasterRosterPeriods(
      period: period ?? this.period,
      orderStarTime: orderStarTime ?? this.orderStarTime,
      orderEndTime: orderEndTime ?? this.orderEndTime,
      meals: meals ?? this.meals,
      locations: locations ?? this.locations,
    );
  }
}







class MealRosterIds {
  final String id;
  final String? name;

  const MealRosterIds({required this.id, this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory MealRosterIds.fromJson(Map<String, dynamic> json) => MealRosterIds(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString(),
  );

  static List<MealRosterIds> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => MealRosterIds.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  MealRosterIds copyWith({String? id, String? name}) =>
      MealRosterIds(id: id ?? this.id, name: name ?? this.name);
}

class MealRosterIdsApiResponse {
  final List<MealRosterIds> items;
  final bool empty;
  final int currentPage;
  final int resultsPerPage;
  final int totalPages;
  final int totalResults;

  const MealRosterIdsApiResponse({
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

  factory MealRosterIdsApiResponse.fromJson(Map<String, dynamic> json) =>
      MealRosterIdsApiResponse(
        items:
            json['items'] is List
                ? MealRosterIds.fromJsonList(json['items'])
                : <MealRosterIds>[],
        empty: _boolValue(json['empty']),
        currentPage: _intValue(json['currentPage']),
        resultsPerPage: _intValue(json['resultsPerPage']),
        totalPages: _intValue(json['totalPages']),
        totalResults: _intValue(json['totalResults']),
      );

  static List<MealRosterIdsApiResponse> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => MealRosterIdsApiResponse.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

  MealRosterIdsApiResponse copyWith({
    List<MealRosterIds>? items,
    bool? empty,
    int? currentPage,
    int? resultsPerPage,
    int? totalPages,
    int? totalResults,
  }) => MealRosterIdsApiResponse(
    items: items ?? this.items,
    empty: empty ?? this.empty,
    currentPage: currentPage ?? this.currentPage,
    resultsPerPage: resultsPerPage ?? this.resultsPerPage,
    totalPages: totalPages ?? this.totalPages,
    totalResults: totalResults ?? this.totalResults,
  );
}

class MealRosterModel {
  final String id;
  final List<ServiceProviderRoster> serviceProviders;

  const MealRosterModel({required this.id, required this.serviceProviders});

  Map<String, dynamic> toJson() => {
    'id': id,
    'serviceProviders': serviceProviders.map((item) => item.toJson()).toList(),
  };

  factory MealRosterModel.fromJson(Map<String, dynamic> json) =>
      MealRosterModel(
        id: json['id']?.toString() ?? '',
        serviceProviders:
            json['serviceProviders'] is List
                ? ServiceProviderRoster.fromJsonList(json['serviceProviders'])
                : <ServiceProviderRoster>[],
      );

  static List<MealRosterModel> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => MealRosterModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  MealRosterModel copyWith({
    String? id,
    List<ServiceProviderRoster>? serviceProviders,
  }) => MealRosterModel(
    id: id ?? this.id,
    serviceProviders: serviceProviders ?? this.serviceProviders,
  );
}

class ServiceProviderRoster {
  final String? serviceProviderId;
  final List<RosterDates> dates;

  const ServiceProviderRoster({this.serviceProviderId, required this.dates});

  Map<String, dynamic> toJson() => {
    'serviceProviderId': serviceProviderId,
    'dates': dates.map((item) => item.toJson()).toList(),
  };

  factory ServiceProviderRoster.fromJson(Map<String, dynamic> json) =>
      ServiceProviderRoster(
        serviceProviderId: json['serviceProviderId']?.toString(),
        dates:
            json['dates'] is List
                ? RosterDates.fromJsonList(json['dates'])
                : <RosterDates>[],
      );

  static List<ServiceProviderRoster> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) =>
                ServiceProviderRoster.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  ServiceProviderRoster copyWith({
    String? serviceProviderId,
    List<RosterDates>? dates,
  }) => ServiceProviderRoster(
    serviceProviderId: serviceProviderId ?? this.serviceProviderId,
    dates: dates ?? this.dates,
  );
}

class RosterDates {
  final String date;
  final List<RosterPeriods> periods;

  const RosterDates({required this.date, required this.periods});

  Map<String, dynamic> toJson() => {
    'date': date,
    'periods': periods.map((item) => item.toJson()).toList(),
  };

  factory RosterDates.fromJson(Map<String, dynamic> json) => RosterDates(
    date: json['date']?.toString() ?? '',
    periods:
        json['periods'] is List
            ? RosterPeriods.fromJsonList(json['periods'])
            : <RosterPeriods>[],
  );

  static List<RosterDates> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map((item) => RosterDates.fromJson(Map<String, dynamic>.from(item)))
          .toList();

  RosterDates copyWith({String? date, List<RosterPeriods>? periods}) =>
      RosterDates(date: date ?? this.date, periods: periods ?? this.periods);
}

class RosterPeriods {
  final String? periodId;
  final String orderStartTime;
  final String orderEndTime;
  final List<String> meals;
  final List<String> canteenIds;

  const RosterPeriods({
    this.periodId,
    required this.orderStartTime,
    required this.orderEndTime,
    required this.meals,
    required this.canteenIds,
  });

  Map<String, dynamic> toJson() => {
    'periodId': periodId,
    'orderStartTime': orderStartTime,
    'orderEndTime': orderEndTime,
    'meals': meals,
    'canteenIds': canteenIds,
  };

  factory RosterPeriods.fromJson(Map<String, dynamic> json) => RosterPeriods(
    periodId: json['periodId']?.toString(),
    orderStartTime: json['orderStartTime']?.toString() ?? '',
    orderEndTime: json['orderEndTime']?.toString() ?? '',
    meals: _stringList(json['meals']),
    canteenIds: _stringList(json['canteenIds']),
  );

  static List<RosterPeriods> fromJsonList(List<dynamic> list) =>
      list
          .whereType<Map>()
          .map(
            (item) => RosterPeriods.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

  RosterPeriods copyWith({
    String? periodId,
    String? orderStartTime,
    String? orderEndTime,
    List<String>? meals,
    List<String>? canteenIds,
  }) => RosterPeriods(
    periodId: periodId ?? this.periodId,
    orderStartTime: orderStartTime ?? this.orderStartTime,
    orderEndTime: orderEndTime ?? this.orderEndTime,
    meals: meals ?? this.meals,
    canteenIds: canteenIds ?? this.canteenIds,
  );
}

final List<Map<String, MealRosterModel>> sampleMealRosters = [
  {
    'user_001': sampleMealRoster,
  },
];

final MealRosterModel sampleMealRoster = MealRosterModel(
  id: 'meal_roster_001',
  serviceProviders: [
    ServiceProviderRoster(
      serviceProviderId: 'service_provider_1',
      dates: [
        RosterDates(
          date: '2026-09-28',
          periods: [
            RosterPeriods(
              periodId: 'breakfast_1',
              orderStartTime: '07:00',
              orderEndTime: '10:00',
              meals: ['meal_001', 'meal_002'],
              canteenIds: ['canteen_001', 'canteen_002'],
            ),
            RosterPeriods(
              periodId: 'lunch_2',
              orderStartTime: '11:00',
              orderEndTime: '14:00',
              meals: ['meal_003', 'meal_004'],
              canteenIds: ['canteen_001', 'canteen_003'],
            ),
          ],
        ),
        RosterDates(
          date: '2026-09-29',
          periods: [
            RosterPeriods(
              periodId: 'dinner_3',
              orderStartTime: '18:00',
              orderEndTime: '21:00',
              meals: ['meal_005', 'meal_006'],
              canteenIds: ['canteen_002', 'canteen_003'],
            ),
          ],
        ),
      ],
    ),
    ServiceProviderRoster(
      serviceProviderId: 'service_provider_2',
      dates: [
        RosterDates(
          date: '2026-09-28',
          periods: [
            RosterPeriods(
              periodId: 'lunch_2',
              orderStartTime: '11:00',
              orderEndTime: '14:00',
              meals: ['meal_007', 'meal_008'],
              canteenIds: ['canteen_001', 'canteen_002'],
            ),
          ],
        ),
      ],
    ),
  ],
);

List<String> _stringList(dynamic value) =>
    value is List
        ? value
            .where((item) => item != null)
            .map((item) => item.toString())
            .toList()
        : <String>[];

int _intValue(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

bool _boolValue(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}
