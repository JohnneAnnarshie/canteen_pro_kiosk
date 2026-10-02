
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class ConnectivityState extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void setConnectivity(bool value) {
    state = value;
  }

  void initConnectivityStream() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result.contains(ConnectivityResult.none)) {
        setConnectivity(false);
      } else {
        setConnectivity(true);
      }
    });
  }
}

final connectivityProvider = NotifierProvider<ConnectivityState, bool>(() {
  return ConnectivityState();
});