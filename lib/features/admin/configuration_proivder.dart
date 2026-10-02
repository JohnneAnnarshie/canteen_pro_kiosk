import 'dart:developer';

import 'package:canteen_pro/models/canteen_setting.dart';
import 'package:canteen_pro/models/meal_time.dart';
import 'package:canteen_pro/network/repos/network_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfigurationState {
  final CanteenSetting? canteenSetting;
  final MealTime? mealServeTime;
  final bool kioskMode;
  final bool soundEnabled;

  const ConfigurationState({
    required this.canteenSetting,
    required this.mealServeTime,
    required this.kioskMode,
    required this.soundEnabled,
  });

  static Map<String, Object> toMap(ConfigurationState state) {
    return {
      'canteenSetting': ?state.canteenSetting?.toMap(),
      'mealServeTime': ?state.mealServeTime?.toJson(),
      'kioskMode': state.kioskMode,
      'soundEnabled': state.soundEnabled,
    };
  }

  static ConfigurationState fromMap(Map<String, dynamic> map) {
    return ConfigurationState(
      canteenSetting: map['canteenSetting'] == null
          ? null : CanteenSetting.fromMap(map['canteenSetting'] as Map<String, dynamic>),
      mealServeTime: map['mealServeTime'] == null
          ? null : MealTime.fromJson(map['mealServeTime'] as Map<String, dynamic>),
      kioskMode: map['kioskMode'] as bool,
      soundEnabled: map['soundEnabled'] as bool
    );
  }


  ConfigurationState copyWith({
    CanteenSetting? canteenSetting,
    MealTime? mealServeTime,
    bool? kioskMode,
    bool? soundEnabled,
  }) {
    return ConfigurationState(
      canteenSetting: canteenSetting ?? this.canteenSetting,
      mealServeTime: mealServeTime ?? this.mealServeTime,
      kioskMode: kioskMode ?? this.kioskMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}

class ConfigurationProvider extends Notifier<ConfigurationState>{
  static const configurationKey = 'canteen_settings_configuration';
  final _prefsRepo = NetworkConfig().prefsRepo;

  @override
  ConfigurationState build() {
    return ConfigurationState(
        canteenSetting: null,
        mealServeTime: null,
        kioskMode: true,
        soundEnabled: true
    );
  }


  Future<void> saveConfiguration(ConfigurationState? configuration) async {
    if (configuration == null) {
      await _prefsRepo.clearItem(configurationKey);
      state = ConfigurationState(
          canteenSetting: null,
          mealServeTime: null,
          kioskMode: true,
          soundEnabled: true
      );
    } else {
      await _prefsRepo.setMap(configurationKey, ConfigurationState.toMap(configuration));
      state = configuration;
    }

  }

  Future<void> loadConfiguration() async {
    final map = await _prefsRepo.getMap(configurationKey);
    if (map != null) {
      state = ConfigurationState.fromMap(map);
      log("CACHED CONFIG: ${state.toString()}");
    } else {
      state = ConfigurationState(
          canteenSetting: null,
          mealServeTime: null,
          kioskMode: true,
          soundEnabled: true
      );
      log("NEW CONFIG: ${state.toString()}");
    }
  }

  Future<void> resetConfiguration() async {
    state = ConfigurationState(
        canteenSetting: null,
        mealServeTime: null,
        kioskMode: true,
        soundEnabled: true
    );
  }
}

final configurationState = NotifierProvider<ConfigurationProvider, ConfigurationState>(() {
  return ConfigurationProvider();
});
