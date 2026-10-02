import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsRepo {
  PrefsRepo._();
  static final PrefsRepo _instance = PrefsRepo._();
  factory PrefsRepo() => _instance;

  late SharedPreferences prefs;
  bool _isInitialized = false;

  /// Must be called once before using any other method — typically in
  /// main() before runApp().
  Future<void> initialize() async {
    if (_isInitialized) return;
    prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    return await prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return prefs.getStringList(key);
  }

  String? getString(String key) {
    return prefs.getString(key);
  }

  Future<bool> setMap(String key, Map<dynamic, dynamic> map) async {
    return await prefs.setString(key, jsonEncode(map));
  }

  Map<String, dynamic>? getMap(String key) {
    final val = prefs.getString(key);
    if (val != null) {
      return jsonDecode(val);
    }
    return null;
  }

  Future<bool> setBool(bool value, String key) async {
    return await prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return prefs.getBool(key);
  }

  Future<bool> clearItem(String key) async {
    return await prefs.remove(key);
  }

  Future<bool> clearAll() async {
    return await prefs.clear();
  }
}