
import 'dart:developer';

import 'package:canteen_pro/config/app_env.dart';
import 'package:canteen_pro/network/repos/secure_prefs_repo.dart';
import 'package:canteen_pro/network/services/auth_session_service.dart';
import 'package:canteen_pro/network/services/network_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../data/db/app_db.dart';
import '../../models/auth.dart';
import '../../models/user.dart';
import '../../services/background_tasks_service.dart';
import '../auth_service.dart';


class NetworkConfig {
  NetworkConfig._();

  static final NetworkConfig _instance = NetworkConfig._();

  factory NetworkConfig() => _instance;

  ///---------------------------------------------------///

  static final clientId = AppEnv.clientId;
  static final redirectUrl = AppEnv.redirectUrl;
  static final discoveryUrl = AppEnv.discoveryUrl;
  static final authEndpoint = AppEnv.authEndpoint;
  static final tokenEndpoint = AppEnv.tokenEndpoint;
  static final endSessionUrl = AppEnv.endSessionUrl;
  static final baseUrl = AppEnv.apiBaseUrl;
  static final postLogoutRedirectUrl = AppEnv.postLogoutRedirectUrl;
  static final scopes = AppEnv.scopes;
  static final clientSecret = AppEnv.clientSecret;

  final AppDb _appDb = AppDb();

  late final SecurePrefsRepo prefsRepo;

  late AuthService authService;

  late User? user;

  Auth? auth;


  Future<void> initialize() async {
    prefsRepo = SecurePrefsRepo(
      storage: const FlutterSecureStorage(),
    );

    await getAuth();

    await getUser();

    //await setTokenRef();

    await initDB();


    authService = AuthService(
        clientId: clientId,
        redirectUrl: redirectUrl,
        discoveryUrl: discoveryUrl,
        postLogoutRedirect: postLogoutRedirectUrl,
        scopes: scopes,
        clientSecret: clientSecret,
        idToken: auth?.idToken ?? '',
        authorizationEndpoint: authEndpoint,
        tokenEndpoint: tokenEndpoint,
        endSessionEndpoint: endSessionUrl
    );

    if (auth != null && user != null) {
    }

  }

  Future<void> initDB() async {
    await _appDb.isTableEmpty("members");
  }

  Future<void> getUser() async {
    final userMap = await AuthSessionService.getUserInfo();
    if (userMap != null) {
      user = User.fromJson(userMap);
      print(user?.toJson());
      log(name:  "APP", "User retrieved successfully");
    } else {
      log(name:  "APP", "No user found");
      user = null;
    }
  }

  Future<void> getAuth() async {
    final authResponse = await AuthSessionService.getAuth();
    if (authResponse != null) {
      auth = authResponse;
    } else {
      log(name:  "APP", "No auth found");
      auth = null;
    }
  }

  Future<void> refreshToken() async {
    AuthSessionService.getRefreshToken();
  }

  Future<void> getAppAuth() async {
    final authResponse = await AuthSessionService.getAuth();
    if (authResponse != null) {
      auth = authResponse;
    }
  }

  Future<String?> getAccessToken() async {
    if (auth == null) {
      return null;
    }
    var token = await AuthSessionService.getAccessToken();
    return token;
  }

  String? getCompanyReference() {
    if (user != null) {
      return user?.accRef;
    }
    return null;
  }

  Future<String> login() async {
    final newAuthMap = await authService.login();
    if (newAuthMap.keys.first.isEmpty) {
      final Auth? newAuth = newAuthMap.values.first;
      if (newAuth == null) {
        return 'Error logging in, please try again';
      }
      auth = newAuth;
      await AuthSessionService.saveTokens(auth: newAuth);

      final claimMap = JwtDecoder.decode(auth!.accessToken);
      final accRef = claimMap['acc_ref'] as String;

      final userInfo = await NetworkHelper().getUserInfo();

      final newUser = User.fromJson(userInfo).copyWith(accRef: accRef.replaceAll("._", ""));
      final updatedUser = newUser.copyWith(accRef: accRef);
      await AuthSessionService.saveUserInfo(userInfo);

      // final tokenRef = {
      //   "access_token": auth!.accessToken,
      //   "acc_ref": accRef.replaceAll("._", "")
      // };
      //await BackgroundTasksService().sendTokenRefToAndroid(tokenRef);
      user = updatedUser;

    }
    return newAuthMap.keys.first;
  }

  Future<void> setTokenRef() async {
    if (auth == null || user == null) {
      log(name: "APP", "No auth or user found");
      return;
    }

    final tokenRef = {
      "access_token": auth?.accessToken,
      "acc_ref": user?.accRef
    };
    //await BackgroundTasksService().sendTokenRefToAndroid(tokenRef);
  }

  Future<void> logout() async {
    await authService.logout();
    await prefsRepo.clearAll();
    await AuthSessionService.clearAll();
  }

}