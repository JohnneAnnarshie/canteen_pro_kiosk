import 'dart:developer';
import 'package:permission_handler/permission_handler.dart';

class PermissionsHandler {
  static Future<bool> requestCameraPermissions() async {
    final status = await Permission.camera.request();

    log(
      name: 'PermissionsHandler',
      'Camera permission: ${status.name}',
    );

    if (status.isDenied) {
      return false;
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      return false;
    }

    return true;
  }

  static Future<bool> requestMicrophonePermissions() async {
    final status = await Permission.microphone.request();

    log(
      name: 'PermissionsHandler',
      'Microphone permission: ${status.name}',
    );

    if (status.isDenied) {
      return false;
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      return false;
    }

    return true;
  }

  static Future<bool> requestPhotoPermissions() async {
    final cameraOk = await requestCameraPermissions();
    final micOk = await requestMicrophonePermissions();

    return cameraOk && micOk;
  }

  static Future<void> requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    log(
      name: 'PermissionsHandler',
      'Notification permission: ${status.name}',
    );
  }

  static Future<bool> requestOnlyLocationPermission() async {
    final status = await Permission.location.request();
    await Permission.locationWhenInUse.request();
    log(
      name: 'PermissionsHandler',
      'Location permission: ${status.name}',
    );

    if (status.isDenied) {
      return false;
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      return false;
    }

    return true;
  }

  static Future<bool> requestBackgroundLocationPermission() async {
    final status = await Permission.locationAlways.request();
    log(
      name: 'PermissionsHandler',
      'Location permission: ${status.name}',
    );
    if (status.isDenied) {
      return false;
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      return false;
    }
    return true;
  }

  static Future<bool> requestLocationPermissions() async {
    final locationOk = await requestOnlyLocationPermission();
    final backgroundOk = await requestBackgroundLocationPermission();
    return locationOk && backgroundOk;
  }

  static Future<bool> getLocationStatus() async {
    return await Permission.location.isGranted && await Permission.locationWhenInUse.isGranted;
  }

  static Future<bool> getBackgroundLocationStatus() async {
    return await Permission.locationAlways.isGranted;
  }


  static Future<PermissionStatus> getCameraStatus() async {
    return await Permission.camera.status;
  }

  static Future<PermissionStatus> getMicrophoneStatus() async {
    return await Permission.microphone.status;
  }

  static Future<bool> requestStoragePermissions() async {
    final status = await Permission.manageExternalStorage.request();
    final status2 = await Permission.storage.request();
    log(
      name: 'PermissionsHandler',
      'Storage permission: ${status.name}',
    );
    return status.isGranted && status2.isGranted;
  }

}

