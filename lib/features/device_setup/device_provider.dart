import 'dart:developer';

import 'package:canteen_pro/models/api_endpoints.dart';
import 'package:canteen_pro/network/services/network_helper.dart';
import 'package:canteen_pro/repositories/repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/device_set_up.dart';
import '../../network/repos/api_repo.dart';
import '../../network/repos/network_config.dart';
import '../../services/prefs_repo.dart';


class DeviceProvider extends Notifier<DeviceSetUp?> {
  static const deviceSetUpKey = 'device_setup';
  static const isDeviceVerifiedKey = 'is_device_verified';
  static final userRepo = UserRepository();
  final PrefsRepo prefsRepo = PrefsRepo();
  final NetworkHelper _netWorkHelper = NetworkHelper();

  bool _isDeviceVerified = false;
  bool get isDeviceVerified => _isDeviceVerified;


  @override
  DeviceSetUp? build() {
    return null;
  }

  Future<void> initialize() async {
    //await getDeviceBySerialNumber(await DeviceInfoService().getDeviceSerialNumber());
    await getDeviceSetup();
    log(name: 'DeviceProvider', 'Initialized');
  }



  Future<void> getDeviceSetup() async {
    final res = prefsRepo.getMap(deviceSetUpKey);
    _isDeviceVerified = prefsRepo.getBool(isDeviceVerifiedKey) ?? false;
    if (res == null) {
      _isDeviceVerified = false;
      return;
    }
    state = DeviceSetUp.fromJson(res);
  }

  void setIsDeviceVerified(bool isVerified) {
    prefsRepo.setBool(isVerified, isDeviceVerifiedKey);
    _isDeviceVerified = isVerified;
    state = state;
  }


  Future<void> saveDeviceSetup(DeviceSetUp? deviceSetup) async {
    if (deviceSetup == null)  {
      await prefsRepo.clearItem(deviceSetUpKey);
      state = null;
      return;
    }
    await prefsRepo.setMap(deviceSetUpKey, deviceSetup.toJson());
    state = deviceSetup;
    log(name: 'DeviceProvider', 'Saved device setup');
  }


  Future<String?> submitDeviceSetup(DeviceSetUp deviceSetup) async {
    try {
      await userRepo.setDeviceConfig(deviceSetup);
      saveDeviceSetup(deviceSetup);
      return null;
    } on Exception catch (e, s) {
      log("ERROR FETCHING DEVICE", error: e, stackTrace: s);
      return e.toString();
    }
  }

  Future<String?> getPhysicalDeviceBySerialNumber(String serial, Function(NetworkPhysicalDevice?) onDeviceFound) async {
    try {
      final finalEndPoint = ApiEndpoint.getPhysicalDeviceBySerialNumber.endPoint
      .replaceFirst("/", "").replaceAll('{serial}', serial);

      final res = await _netWorkHelper.get(finalEndPoint);

      final device = NetworkPhysicalDevice.fromJson(res);
      onDeviceFound(device);
      return null;
    } on Exception catch (e, s) {
      log("ERROR FETCHING DEVICE", error: e, stackTrace: s);
      return e.toString();
    }
  }

  Future<String?> getDeviceByCode(String code, Function(NetworkDeviceSetUp?) onDeviceFound) async {
    try {
      final finalEndPoint = ApiEndpoint.getDeviceSetUpByCode.endPoint
      .replaceFirst("/", "").replaceAll('{code}', code);

      final res = await _netWorkHelper.get(finalEndPoint);

      final device = NetworkDeviceSetUp.fromJson(res);
      onDeviceFound(device);
      return null;
    } on Exception catch (e, s) {
      log("ERROR FETCHING DEVICE", error: e, stackTrace: s);
      return e.toString();
    }
  }
}

final deviceSetUpProvider = NotifierProvider<DeviceProvider, DeviceSetUp?>(() {
  return DeviceProvider();
});