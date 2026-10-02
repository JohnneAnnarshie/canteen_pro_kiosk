import 'package:canteen_pro/features/pre_order/pre_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../app.dart';


class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Initialize the plugin
  static Future<void> initialize() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap (works for both Android and iOS)
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => const PreOrderScreen()),
        );
      },
    );

    // Request iOS permissions
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation
      <IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Show a local notification
  static Future<void> show({ required String title, required String body,
    String? payload, int id = 1}) async {
      AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        Uuid().v4().toString(),
        'TimeTrakker',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        colorized: true,
        color: Colors.blue,
        enableVibration: true,
        icon: 'ic_launcher_foreground',
        autoCancel: false, // Notification won't auto-dismiss
      );

      const DarwinNotificationDetails iosPlatformChannelSpecifics =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
      );
      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
  }
}

