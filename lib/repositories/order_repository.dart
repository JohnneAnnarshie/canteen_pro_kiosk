import '../models/batch_order.dart';
import '../models/clock_in_meal.dart';
import '../models/order.dart';
import '../network/services/network_helper.dart';
import 'repository_helpers.dart';

class OrderRepository {
  OrderRepository({NetworkHelper? networkHelper})
    : _networkHelper = networkHelper ?? NetworkHelper();

  final NetworkHelper _networkHelper;

  Future<void> createUserOrder(OrderApiDto order) async {
    final response = await _networkHelper.post('Order', body: order.toJson());
    requireSuccess(response);
  }

  Future<void> serveOrder(ServeOrderDto order) async {
    final response = await _networkHelper.put('Order', body: order.toJson());
    requireSuccess(response);
  }

  Future<List<Order>> getAllOrders() async {
    final items = await _networkHelper.getList('Order/orders');
    return Order.fromJsonList(items);
  }

  Future<List<Order>> getUserOrder(String employeeId) async {
    final items = await _networkHelper.getList('Order/order/$employeeId');
    return Order.fromJsonList(items);
  }

  Future<List<ServeOrderDto>> getOrderDetails(String orderId) async {
    final items = await _networkHelper.getList('Order/orderDetail/$orderId');
    return ServeOrderDto.fromJsonList(items);
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

  Future<List<BatchOrder>> getAllBatchOrders() async {
    final items = await _networkHelper.getList('Order/badgedFoods');
    return BatchOrder.fromJsonList(items);
  }

  Future<void> createClockInMeal(ClockInMealDto meal) async {
    final response = await _networkHelper.post(
      'Order/clockInMeal',
      body: meal.toJson(),
    );
    requireSuccess(response);
  }
}
