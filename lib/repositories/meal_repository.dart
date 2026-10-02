import '../models/active_meal.dart';
import '../models/meal.dart';
import '../models/meal_time.dart';
import '../network/services/network_helper.dart';
import 'repository_helpers.dart';

class MealRepository {
  MealRepository({NetworkHelper? networkHelper})
    : _networkHelper = networkHelper ?? NetworkHelper();

  final NetworkHelper _networkHelper;

  Future<List<Meal>> fetchMeals() async {
    final json = await _networkHelper.get('Meal/mealSetup');
    return MealItem.fromJsonList(
      asJsonList(json['items']),
    ).map((item) => item.toMeal()).toList();
  }

  Future<List<ActiveMeal>> fetchActiveMeals() async {
    final items = await _networkHelper.getList('Meal/activeMealSetup');
    return ActiveMeal.fromJsonList(items);
  }

  Future<Meal> fetchMealById(String id) async {
    final json = await _networkHelper.get('Meal/meal/$id');
    return MealItem.fromJson(json).toMeal();
  }

  Future<MealTimeApiResponse> fetchMealTimes({int page = 1}) async {
    final json = await _networkHelper.get('Meal/mealTime?page=$page');
    return MealTimeApiResponse.fromJson(json);
  }

  Future<MealTime> fetchMealTimeById(String id) async {
    final json = await _networkHelper.get('Meal/mealTime/$id');
    return MealTime.fromJson(json);
  }
}
