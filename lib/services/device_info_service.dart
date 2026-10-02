
import 'dart:developer';

import 'package:flutter/services.dart';

class DeviceInfoService {
  DeviceInfoService._();
  static final DeviceInfoService _instance = DeviceInfoService._();
  factory DeviceInfoService() => _instance;
  static const _channel = MethodChannel('canteen/main_channel');


  /// Returns a device identifier usable in place of a true hardware serial.
  ///
  /// NOTE: Android 10+ blocks access to the real hardware serial number
  /// (Build.getSerial()) for all non-system apps — this is an OS-level
  /// restriction, not something this plugin or your app can bypass.
  /// This returns Android ID instead: a unique-per-device (per-app on
  /// some OEMs) identifier that's the standard substitute.
  Future<String> getDeviceSerialNumber() async {
    try {
      final result = await _channel.invokeMethod<String>('getDeviceSerial');
      return result ?? '';
    } on PlatformException catch (e) {
      log(name: 'DeviceInfoService', 'Failed to get device serial: ${e.message}');
      return '';
    }
  }
}