import '../models/active_meal.dart';
import '../models/batch_order.dart';
import '../models/canteen_setting.dart';
import '../models/meal.dart';
import '../models/meal_roster.dart';
import '../models/meal_time.dart';
import '../models/order.dart';
import '../models/service_provider.dart';
import '../models/user_category.dart';
import '../network/services/network_helper.dart';
import 'repository_helpers.dart';

class ServerRepository {
  ServerRepository({NetworkHelper? networkHelper})
    : _networkHelper = networkHelper ?? NetworkHelper();

  final NetworkHelper _networkHelper;

  Future<void> serveOrder(ServeOrderDto order) async {
    final response = await _networkHelper.put('Order', body: order.toJson());
    requireSuccess(response);
  }

  Future<List<ServeOrderDto>> getOrderDetails(String orderId) async {
    final items = await _networkHelper.getList('Order/orderDetail/$orderId');
    return ServeOrderDto.fromJsonList(items);
  }

  Future<Order> getOrderByOrderId(String orderId) async {
    final json = await _networkHelper.get(
      'Order/orderdata?orderId=${Uri.encodeQueryComponent(orderId)}',
    );
    return Order.fromJson(json);
  }

  Future<Order> getOrderDataByOrderId(String orderId) async {
    final json = await _networkHelper.get(
      'Order/orderdata?orderId=${Uri.encodeQueryComponent(orderId)}',
    );
    return Order.fromJson(json);
  }

  Future<MemberCategory> getUserCategoryById(String id) async {
    final json = await _networkHelper.get('CanteenSetting/userCategory/$id');
    return MemberCategory.fromJson(json);
  }

  Future<List<MealRosterModel>> getMealRosterByUserId(String userId) async {
    final items = await _networkHelper.getList('Meal/mealRoster/$userId');
    return MealRosterModel.fromJsonList(items);
  }

  Future<ActiveMeal> fetchMealById(String id) async {
    final json = await _networkHelper.get('Meal/meal/$id');
    return MealItem.fromJson(json).toActiveMeal();
  }

  Future<CanteenSetting> getCanteenSettingById(String id) async {
    final json = await _networkHelper.get('CanteenSetting/location/$id');
    return CanteenSetting.fromJson(json);
  }

  Future<MealTime> fetchMealTimeById(String id) async {
    final json = await _networkHelper.get('Meal/mealTime/$id');
    return MealTime.fromJson(json);
  }

  Future<ServiceProvider> fetchServiceProviderById(String id) async {
    final json = await _networkHelper.get(
      'ServiceProvider/serviceProvider/$id',
    );
    return ServiceProvider.fromJson(json);
  }

  Future<void> createBatchOrder(BatchOrderDto order) async {
    final response = await _networkHelper.post(
      'Order/badgeEntity',
      body: order.toJson(),
    );
    requireSuccess(response);
  }

  Future<List<BatchOrder>> getBatchOrdersByUserId(String userId) async {
    final items = await _networkHelper.getList('Order/badgedFood/$userId');
    return BatchOrder.fromJsonList(items);
  }
}
