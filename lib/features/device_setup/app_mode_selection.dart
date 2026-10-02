
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/prefs_repo.dart';

enum AppMode {
  admin(code: 'admin'),
  driver(code: 'driver');

  final String code;
  const AppMode({required this.code});
}

class AppModeSateNotifier extends Notifier<AppMode?> {
  static const appModeKey = 'appMode';
  final PrefsRepo _prefsRepo = PrefsRepo();

  @override
  AppMode? build() => null;

  Future<void> initialize() async {
    final mode = _prefsRepo.getString(appModeKey);
    if (mode != null) {
      state = AppMode.values.firstWhere((e) => e.code == mode);
    }
  }

  void setMode(AppMode? mode) async {
    if (mode == null) {
      await _prefsRepo.clearItem(appModeKey);
      state = null;
      return;
    }
    await _prefsRepo.setString(appModeKey, mode.code);
    state = mode;
  }
}

final appModeStateProvider = NotifierProvider<AppModeSateNotifier, AppMode?>(
      () => AppModeSateNotifier(),
);