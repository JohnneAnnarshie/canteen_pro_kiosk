import 'dart:developer';

import 'package:canteen_pro/models/active_meal.dart';
import 'package:canteen_pro/models/canteen_setting.dart';
import 'package:canteen_pro/models/meal.dart';
import 'package:canteen_pro/models/meal_roster.dart';
import 'package:canteen_pro/models/meal_time.dart';
import 'package:canteen_pro/models/models.dart';
import 'package:canteen_pro/repositories/meal_repository.dart';
import 'package:canteen_pro/repositories/meal_roster_repository.dart';
import 'package:canteen_pro/repositories/order_repository.dart';
import 'package:canteen_pro/repositories/repositories.dart';
import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/order.dart';
import '../../models/service_provider.dart';
import '../../network/repos/network_config.dart';
import '../admin/configuration_proivder.dart';
import '../landing/get_started_provider.dart';

enum PreOrderScreenState { loading, error, success }

class PreOrderState extends Equatable {
  final PreOrderScreenState state;
  final MasterMealRoster? roster;

  final String? errorMessage;

  const PreOrderState({required this.state,
    this.roster, this.errorMessage});

  PreOrderState copyWith({
    PreOrderScreenState? state,
    MasterMealRoster? roster,
    String? errorMessage,
  }) {
    return PreOrderState(
      state: state ?? this.state,
      roster: roster ?? this.roster,
      errorMessage: errorMessage ?? this.errorMessage
    );
  }

  @override
  List<Object?> get props => [state, roster, errorMessage];

}

class OrderProvider extends Notifier<PreOrderState?> {
  static const _providerTag = 'OrderProvider';
  static final OrderRepository _orderRepository = OrderRepository();
  static final MealRosterRepository _rosterRepository = MealRosterRepository();
  static final MealRepository _mealRepository = MealRepository();
  static final UserRepository _userRepository = UserRepository();
  static final ServiceProviderRepository _providerRepository =
      ServiceProviderRepository();

  Member? _currentMember;
  Member? get currentMember => _currentMember;

  MemberCategory? _currentMemberCategory;
  MemberCategory? get currentMemberCategory => _currentMemberCategory;


  final List<ActiveMeal> _meals = [];
  List<ActiveMeal> get meals => _meals;

  final List<ServiceProvider> _providers = [];
  List<ServiceProvider> get providers => _providers;

  final List<CanteenSetting> _canteenSettings = [];
  List<CanteenSetting> get canteenSettings => _canteenSettings;

  final List<MealTime> _mealTimes = [];
  List<MealTime> get mealTimes => _mealTimes;

  final List<SelectedActiveMeal> _selectedMeals = [];
  List<SelectedActiveMeal> get selectedMeals => _selectedMeals;

  final Set<Order> _orders = {};
  Set<Order> get orders => _orders;

  final Set<String> _orderMealIds = {};
  Set<String> get orderMealIds => _orderMealIds;


  MealRosterModel? _modelRoster;
  MealRosterModel? get modelRoster => _modelRoster;

  MasterMealRoster? _masterMealRoster;
  MasterMealRoster? get masterMealRoster => _masterMealRoster;

  ServiceProvider? _currentProvider;
  ServiceProvider? get currentProvider => _currentProvider;



  String? _currentDate;
  String? get currentDate => _currentDate;


  @override
  PreOrderState? build() {
    return null;
  }

  void addActiveMeal({
    required ActiveMeal meal,
    required String selectedMealId,
    required int quantity,
    required String provider,
    required String periodId,
    required String date,
    required String mealTypeName,
    required String location,
    required String mealRoserId
  }) {
    _selectedMeals.add(
        SelectedActiveMeal(
          id: selectedMealId,
          meal: meal,
          quantity: quantity,
          provider: provider,
          periodId: periodId,
          availableDate: date,
          locationId: location,
          mealType: mealTypeName,
          mealRosterId: mealRoserId
        )
    );
  }

  void updateSelectedActiveMeal(String selectedMealId, {
    int? quantity,
    String? location,
  }) {
    final selectedMeal = _selectedMeals.firstWhereOrNull((meal) => meal.id == selectedMealId);
    if (selectedMeal != null) {
      var updatedMeal = selectedMeal.copyWith(
        quantity: quantity ,
        locationId: location,
      );
      _selectedMeals[_selectedMeals.indexOf(selectedMeal)] = updatedMeal;

      print('Updated selected meal: ${updatedMeal.toJson()}');
      print('Updated selected meals: ${_selectedMeals.map((meal) => meal.toJson()).toList()}');
    }
  }

  void removeSelectedActiveMeal(String selectedMealId) {
    _selectedMeals.removeWhere((meal) => meal.id == selectedMealId);
  }

  void clearSelectedMeals() {
    _selectedMeals.clear();
    state = state;
  }

  bool isAddedToCart(String selectedMealId) {
    return _selectedMeals.where((meal) => meal.id == selectedMealId).isNotEmpty;
  }


  Future<String?> fetchMemberByStaffId(String memberId,
      { required Function(Member) onMemberFound }) async {
    try {
      final member = await UserRepository().fetchUsersByStaffId(memberId);
      final memberCategory = await _userRepository.getUserCategoryById(member.categoryId);
      _currentMember = member;
      _currentMemberCategory = memberCategory;
      onMemberFound(member);
      return null;
      } catch (e, s) {
      log(_providerTag, error: e, stackTrace: s);
      return e.toString();
    }
  }

  Future<void> fetchRosterByMemberId(String memberId) async {
    try {
      state = const PreOrderState(state: PreOrderScreenState.loading);
      final roster = await _rosterRepository.getMealRosterByUserId(memberId);
      await getCurrentMemberOrders(memberId);
      if (roster.isNotEmpty) {
        _modelRoster = roster.first;
        await parseMealRosterModel(_modelRoster!);

        _currentProvider = _masterMealRoster?.serviceProviders.firstOrNull?.serviceProvider;

        _currentDate = _masterMealRoster?.serviceProviders.expand((sp)
        => sp.dates).toList().firstOrNull?.date;

        state = PreOrderState(
          state: PreOrderScreenState.success,
          roster: _masterMealRoster,
        );
      } else {
        state = const PreOrderState(
          state: PreOrderScreenState.success,
          errorMessage: 'No roster found',
        );
      }
    } catch (e, s) {
      state = PreOrderState(
        state: PreOrderScreenState.error,
        errorMessage: e.toString(),
      );
      if (e.toString().contains('token')) {

        await ref.read(getStartedState.notifier).setGetStarted(false);
        await NetworkConfig().logout();
      }
      log(_providerTag, error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> parseMealRosterModel(MealRosterModel rosterModel) async {
    try {
      await createMasterMealRoster(rosterModel);
    } catch (e, s) {
      log(_providerTag, error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<MasterMealRoster> createMasterMealRoster(
    MealRosterModel modelRoster,
  ) async {

    final serviceProviders = await Future.wait(
      modelRoster.serviceProviders.map((providerRoster) async {
        final serviceProviderId = providerRoster.serviceProviderId;
        if (serviceProviderId == null || serviceProviderId.isEmpty) {
          throw StateError(
            'Meal roster contains a service provider without an ID.',
          );
        }

        final serviceProvider = await _providerRepository
            .fetchServiceProviderById(serviceProviderId);
        final dates = await Future.wait(
          providerRoster.dates.map((dateRoster) async {
            final periods = await Future.wait(
              dateRoster.periods.map((periodRoster) async {
                final periodId = periodRoster.periodId;
                if (periodId == null || periodId.isEmpty) {
                  throw StateError(
                    'Meal roster contains a period without an ID.',
                  );
                }

                final period = await _mealRepository.fetchMealTimeById(
                  periodId,
                );

                final meals = await Future.wait(
                  periodRoster.meals.map(
                    (mealId) => _mealRepository.fetchMealById(mealId),
                  ),
                );


                final locations = await Future.wait(
                  periodRoster.canteenIds.map(
                    _rosterRepository.getCanteenSettingById,
                  ),
                );

                final orderStarTime = periodRoster.orderStartTime;
                final orderEndTime = periodRoster.orderEndTime;


                return MasterRosterPeriods(
                  period: period,
                  orderStarTime: orderStarTime,
                  orderEndTime: orderEndTime,
                  meals: meals,
                  locations: locations,
                );
              }),
            );
            return MasterRosterDates(date: dateRoster.date, periods: periods);
          }),
        );

        return MasterRosterServiceProvider(
          serviceProvider: serviceProvider,
          dates: dates,
        );
      }),
    );

    final masterRoster = MasterMealRoster(
      id: modelRoster.id,
      serviceProviders: serviceProviders,
    );

    _masterMealRoster = masterRoster;
    _providers
      ..clear()
      ..addAll(
        masterRoster.serviceProviders.expand(
          (provider) => [provider.serviceProvider],
        ),
      );
    _meals
      ..clear()
      ..addAll(
        masterRoster.serviceProviders
            .expand((provider) => provider.dates)
            .expand((date) => date.periods)
            .expand((period) => period.meals)
            .map(
              (meal) => ActiveMeal(
                id: meal.id,
                name: meal.mealName,
                description: meal.description,
              ),
            ),
      );
    _mealTimes
      ..clear()
      ..addAll(
        masterRoster.serviceProviders
            .expand((provider) => provider.dates)
            .expand((date) => date.periods)
            .map((period) => period.period),
      );
    _canteenSettings
      ..clear()
      ..addAll(
        masterRoster.serviceProviders
            .expand((provider) => provider.dates)
            .expand((date) => date.periods)
            .expand((period) => period.locations),
      );

    return masterRoster;
  }

  Future<void> getCurrentMemberOrders(String memberId) async {
    final orderRes = await _orderRepository.getUserOrder(memberId);
    _orders.clear();
    _orders.addAll(orderRes);
    setOrderedMealIdList(orderRes.toSet());
  }

  Future<String?> submitMemberOrder({
    required List<Meal> meals,
    required int quantity,
    required String availableDate,
    required String locationId,
    required String periodId,
  }) async {
    try {
      if (_currentMember == null) {
        return 'Member not found';
      }

      final billingEntityId = _currentMember?.billingEntityId;

      if (billingEntityId == null) {
        return 'Billing entity not found';
      }

      if (meals.isEmpty) {
        return 'No meals selected';
      }

      final newOrderItems = meals.map((meal) {
        return Order(
          employeeId: _currentMember?.id,
          mealId: meal.id,
          quantity: quantity,
          availableDate: availableDate,
          periodId: periodId,
          billingEntityId: billingEntityId,
          locationId: locationId,
          mealRosterId: _masterMealRoster?.id,
        ).toOrderItem();
      }).toList();

      await _orderRepository.createUserOrder(newOrderItems.toOrderApiDto());
      await getCurrentMemberOrders(_currentMember?.id ?? '');
      _selectedMeals.clear();
      state = state;
      return null;
    } catch (e, s) {
      log(_providerTag, error: e, stackTrace: s);
      return e.toString();
    }

  }

  Future<String?> submitSelectedMeals() async {
    try {

      if (_currentMember == null) {
        return 'Member not found';
      }

      if (_selectedMeals.isEmpty) {
        return 'No meals selected';
      }


      final billingEntityId = _currentMember!.billingEntityId;
      final orderItems = <OrderItem>[];
      for (final selectedMeal in _selectedMeals) {
        if (selectedMeal.locationId.isEmpty) {
          return 'Please choose a serving location for ${selectedMeal.meal.name}.';
        }
        orderItems.add(
          Order(
            employeeId: _currentMember!.id,
            mealId: selectedMeal.meal.id,
            quantity: selectedMeal.quantity,
            availableDate: selectedMeal.availableDate,
            periodId: selectedMeal.periodId,
            billingEntityId: billingEntityId,
            locationId: selectedMeal.locationId,
            mealRosterId: selectedMeal.mealRosterId ?? _masterMealRoster?.id,
          ).toOrderItem(),
        );
      }

      await _orderRepository.createUserOrder(orderItems.toOrderApiDto());
      await getCurrentMemberOrders(_currentMember!.id);
      _selectedMeals.clear();
      state = state;
      return null;
    } catch (e, s) {
      log(_providerTag, error: e, stackTrace: s);
      return e.toString();
    }
  }

  Future<void> setOrderedMealIdList(Set<Order> ordersSet) async {
    final formattedIds = ordersSet.map((order) => "${order.mealId}${order.periodId}${order.availableDate}").toList();
    _orderMealIds.clear();
    _orderMealIds.addAll(formattedIds);
  }


  Future<void> clearOrderState() async {
    _orders.clear();
    _orderMealIds.clear();
    _selectedMeals.clear();
    _masterMealRoster = null;
    _modelRoster = null;
    _currentProvider = null;
    _currentDate = null;
    _currentMember = null;
    _currentMemberCategory = null;
    _canteenSettings.clear();
    _mealTimes.clear();
    _meals.clear();
    _providers.clear();
    state = null;
  }

}


final orderState = NotifierProvider<OrderProvider, PreOrderState?>(() {
  return OrderProvider();
});
