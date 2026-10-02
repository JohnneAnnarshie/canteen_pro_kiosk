import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurePrefsRepo {
  SecurePrefsRepo({required this.storage});

  final FlutterSecureStorage storage;

  Future<void> setString(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  Future<String?> getString(String key) async {
    return await storage.read(key: key);
  }

  Future<void> setStringList(
      String key,
      List<String> value,
      ) async {
    await storage.write(
      key: key,
      value: jsonEncode(value),
    );
  }

  Future<List<String>?> getStringList(
      String key,
      ) async {
    final value = await storage.read(key: key);

    if (value == null) return null;

    return List<String>.from(jsonDecode(value));
  }

  Future<bool> setMap(
      String key,
      Map<dynamic, dynamic> map,
      ) async {
    await storage.write(
      key: key,
      value: jsonEncode(map),
    );
    return true;
  }

  Future<Map<String, dynamic>?> getMap(
      String key,
      ) async {
    final value = await storage.read(key: key);

    if (value == null) return null;

    return Map<String, dynamic>.from(
      jsonDecode(value),
    );
  }

  Future<void> setList(
      String key,
      List<dynamic> list
      ) async {
    await storage.write(
      key: key,
      value: jsonEncode(list),
    );
  }

  Future<List<dynamic>?> getList(String key) async {
    final value = await storage.read(key: key);

    if (value == null) return null;

    return List<dynamic>.from(jsonDecode(value));
  }


  Future<void> setBool(
      bool value,
      String key,
      ) async {
    await storage.write(
      key: key,
      value: value.toString(),
    );
  }

  Future<bool?> getBool(String key) async {
    final value = await storage.read(key: key);

    if (value == null) return null;

    return value.toLowerCase() == 'true';
  }

  Future<void> setInt(
      String key,
      int value,
      ) async {
    await storage.write(
      key: key,
      value: value.toString(),
    );
  }

  Future<int?> getInt(String key) async {
    final value = await storage.read(key: key);

    if (value == null) return null;

    return int.tryParse(value);
  }

  Future<void> setDouble(
      String key,
      double value,
      ) async {
    await storage.write(
      key: key,
      value: value.toString(),
    );
  }

  Future<double?> getDouble(String key) async {
    final value = await storage.read(key: key);

    if (value == null) return null;

    return double.tryParse(value);
  }


  Future<void> clearItem(String key) async {
    await storage.delete(key: key);
  }


  Future<void> clearAll() async {
    await storage.deleteAll();
  }

  Future<void> clearWithOutPin() async {
    await storage.delete(key: 'auth');
    await storage.delete(key: 'user');
    await storage.delete(key: 'company');
    await storage.delete(key: 'app_initialized');
  }
}