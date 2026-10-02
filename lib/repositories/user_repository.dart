import '../models/member.dart';
import '../models/device_set_up.dart';
import '../models/user_category.dart';
import '../network/services/network_helper.dart';
import 'repository_helpers.dart';

class UserRepository {
  UserRepository({NetworkHelper? networkHelper})
    : _networkHelper = networkHelper ?? NetworkHelper();

  final NetworkHelper _networkHelper;

  Future<UserApiResponse> fetchUsers({int page = 1, String filter = ''}) async {
    final json = await _networkHelper.get(
      'Staff?${filter.isEmpty ? '' : 'filter=$filter&'}page=$page',
    );
    return UserApiResponse.fromJson(json);
  }

  Future<UserApiResponse> fetchUsersByName({String name = ''}) async {
    final filter = Uri.encodeQueryComponent(name);
    final json = await _networkHelper.get('Staff?filter=$filter');
    return UserApiResponse.fromJson(json);
  }

  Future<Member> fetchUsersByStaffId(String staffId) async {
    final json = await _networkHelper.get('Staff/$staffId');
    return Member.fromJson(json);
  }

  Future<void> updateUser(Member user) async {
    final response = await _networkHelper.put(
      'Staff/security',
      body: UserSecurity(staffSecurities: [user.toUserItem()]).toJson(),
    );
    requireSuccess(response);
  }

  Future<Member> fetchUserById(String id) async {
    final json = await _networkHelper.get('users/$id');
    return Member.fromJson(json);
  }

  Future<List<MemberCategory>> getUserCategories() async {
    final json = await _networkHelper.get('CanteenSetting/userCategories');
    return MemberCategory.fromJsonList(asJsonList(json['items']));
  }

  Future<MemberCategory> getUserCategoryById(String id) async {
    final json = await _networkHelper.get('CanteenSetting/userCategory/$id');
    return MemberCategory.fromJson(json);
  }

  Future<void> setDeviceConfig(DeviceSetUp deviceConfig) async {
    final response = await _networkHelper.post(
      'DeviceSetup/physicalDevice',
      body: deviceConfig.toJson(),
    );
    requireSuccess(response);
  }

  Future<List<NetworkDeviceSetUp>> getAllDeviceSetUps() async {
    final json = await _networkHelper.get('DeviceSetup');
    return NetworkDeviceSetUp.fromJsonList(asJsonList(json['items']));
  }

  Future<NetworkDeviceSetUp> getDeviceSetUpByCode(String code) async {
    final json = await _networkHelper.get('DeviceSetup/deviceSetup/$code');
    return NetworkDeviceSetUp.fromJson(json);
  }

  Future<NetworkPhysicalDevice> getPhysicalDeviceBySerialNumber(
    String serialNumber,
  ) async {
    final json = await _networkHelper.get(
      'DeviceSetup/physicaldeviceSetup/$serialNumber',
    );
    return NetworkPhysicalDevice.fromJson(json);
  }
}
