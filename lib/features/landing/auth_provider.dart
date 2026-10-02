import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models/user.dart';
import '../../../services/prefs_repo.dart';
import '../../network/repos/network_config.dart';
import '../../network/repos/secure_prefs_repo.dart';

enum UserRole { driver, admin, unauthenticated }

class AuthState {
  final UserRole role;
  final String? userId;

  const AuthState({this.role = UserRole.unauthenticated, this.userId});
}


class SharedAuthState extends Notifier<User?> {
  final SecurePrefsRepo prefsRepo = NetworkConfig().prefsRepo;
  @override
  User? build() {
    return null;
  }

  void initialize() async {
    await getUser();
  }

  Future<void> setUser(User user) async {
    await prefsRepo.setMap('user', user.toJson());
    state = user;
  }

  void logout() async {
    await prefsRepo.clearItem('user');
    state = null;
  }

  Future<void> getUser() async {
    final res = await prefsRepo.getMap('user');
    if (res == null) {
      return;
    }
    state = User.fromJson(res);
  }

  bool get isAuthenticated => state != null;

  User get currentUser => state!;
}


final currentAuthProvider = NotifierProvider<SharedAuthState, User?>(() {
  return SharedAuthState();
});