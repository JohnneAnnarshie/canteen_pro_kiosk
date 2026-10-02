import '../models/canteen_setting.dart';
import '../models/meal_roster.dart';
import '../network/services/network_helper.dart';
import 'repository_helpers.dart';

class MealRosterRepository {
  MealRosterRepository({NetworkHelper? networkHelper})
    : _networkHelper = networkHelper ?? NetworkHelper();

  final NetworkHelper _networkHelper;

  // Future<List<MasterMealRoster>> getUpcomingRosters(String id) async {
  //   final json = await _networkHelper.get('Meal/mealRoster/$id');
  //   return MasterMealRoster.fromJsonList(asJsonList(json['items']));
  // }

  Future<List<MealRosterModel>> getMealRosterByUserId(String userId) async {
    final items = await _networkHelper.getList('Meal/mealRoster/$userId');
    return MealRosterModel.fromJsonList(items);
  }

  Future<List<MealRosterIds>> getUpcomingRosterIds() async {
    final json = await _networkHelper.get('Meal/roster');
    return MealRosterIds.fromJsonList(asJsonList(json['items']));
  }

  Future<CanteenSettingApiResponse> getCanteenSettings({int page = 1}) async {
    final json = await _networkHelper.get('CanteenSetting?page=$page');
    return CanteenSettingApiResponse.fromJson(json);
  }

  Future<CanteenSetting> getCanteenSettingById(String id) async {
    final json = await _networkHelper.get('CanteenSetting/location/$id');
    return CanteenSetting.fromJson(json);
  }
}
