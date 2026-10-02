import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Starts/stops native Android background location tracking, and ensures
/// native code knows the exact path to your existing sqflite database
/// table directly — no separate database is created on the native side.
class BackgroundTasksService {
  BackgroundTasksService._();
  static final BackgroundTasksService instance = BackgroundTasksService._();
  factory BackgroundTasksService() => instance;


  static const _channel = MethodChannel('canteen/main_channel');
  static const _secureChannel = MethodChannel('secure_bridge');

  // /// Call this once at app startup (e.g. in main() or right after your
  // /// sqflite database is first opened), before calling startTracking().
  // /// This tells native code exactly where timetrakker_mobile.db lives.
  // Future<void> registerDatabasePath() async {
  //   try {
  //     final dir = await getApplicationDocumentsDirectory();
  //     final path = p.join(dir.path, 'timetrakker_mobile.db');
  //
  //     await _channel.invokeMethod('setDatabasePath', {'path': path});
  //     log(name: 'BackgroundTasksService', 'Database path registered: $path');
  //   } on PlatformException catch (e) {
  //     log(name: 'BackgroundLocationService', 'Failed to register db path: ${e.message}');
  //   }
  // }

  // Future<bool> startTracking() async {
  //   try {
  //     final result = await _channel.invokeMethod<bool>('startLocationTracking');
  //     log(name: 'BackgroundLocationService', 'Tracking started: $result');
  //     return result ?? false;
  //   } on PlatformException catch (e) {
  //     log(name: 'BackgroundLocationService', 'Failed to start tracking: ${e.message}');
  //     return false;
  //   }
  // }
  //
  // Future<bool> stopTracking() async {
  //   try {
  //     final result = await _channel.invokeMethod<bool>('stopLocationTracking');
  //     log(name: 'BackgroundLocationService', 'Tracking stopped: $result');
  //     return result ?? false;
  //   } on PlatformException catch (e) {
  //     log(name: 'BackgroundLocationService', 'Failed to stop tracking: ${e.message}');
  //     return false;
  //   }
  // }


  // Future<void> sendTokenRefToAndroid(Map<String, dynamic> tokenRef) async {
  //   try {
  //     _secureChannel.setMethodCallHandler((call) async {
  //       if (call.method == "getSecureValue") {
  //         return tokenRef;
  //       }
  //     });
  //   } on PlatformException catch (e) {
  //     log(name: 'BackgroundLocationService',
  //         'Failed to set method call handler: ${e.message}');
  //   }
  // }
}