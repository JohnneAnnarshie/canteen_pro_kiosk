import 'dart:developer';

import 'package:canteen_pro/network/repos/network_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/prefs_repo.dart';

class GetStartedState extends Notifier<bool> {
  static const getStartedKey = 'get_started';
  final PrefsRepo prefsRepo = PrefsRepo();

  @override
  bool build() => false;

  void getIsGetStarted() {
    final res = prefsRepo.getBool(getStartedKey);
    // final auth = NetworkConfig().auth;
    if (res == null) {
      state = false;
      log(name: 'GetStartedState', 'Get started: $res');
      return;
    }
    state = res;
    log(name: 'GetStartedState', 'Get started: $res');
  }

  Future<void> setGetStarted(bool val) async {
    await prefsRepo.setBool(val, getStartedKey);
    state = val;
  }
}

final getStartedState = NotifierProvider<GetStartedState, bool>(() {
  return GetStartedState();
});