import 'package:flutter/foundation.dart';

import '../network/api_urls.dart';

/// Environment-specific API and auth hosts.
/// Debug/Profile: existing dev hosts (psl-webapps-vm3).
/// Release: production hosts (crm-api.persol-apps.com, crm-auth.persol-apps.com).
class AppEnv {
  AppEnv._();

  static const String _devApiHost = 'https://api-canteen.persol-apps.com';
  static const String _devAuthHost = 'https://auth.persol-apps.com';
  static const String _prodApiHost = 'https://crm-api.persol-apps.com';
  static const String _prodAuthHost = 'https://crm-auth.persol-apps.com';
  // static const String _prodApiHost = 'https://lunch-auth.persolqa.com';
  // static const String _prodAuthHost = 'https://api-canteen.persolqa.com';

  static String get _apiHost => kReleaseMode ? _devApiHost : _devApiHost;
  static String get _authHost => kReleaseMode ? _devAuthHost : _devAuthHost;

  static String get apiBaseUrl => '$_apiHost/';
  static String get authBaseUrl => _authHost;
  static String get discoveryUrl => '$_authHost/.well-known/openid-configuration';
  static final authEndpoint = '$_authHost/connect/authorize';
  static String get userInfoUrl => '$_authHost/connect/userinfo';

  static final tokenEndpoint = '$_authHost/connect/token';
  static final endSessionUrl = '$_authHost/connect/endsession';


  static const clientSecret = "yBGX2m)JxZxc^Io7#m12'2{8_oZE.3";
  static const clientId = 'lunch-standard-ui';
  static const String redirectUrl = 'com.persol.canteenpro:/';
  static const postLogoutRedirectUrl = 'com.persol.canteenpro:/';
  static const scopes = [
    "lunch_api",
    "offline_access",
    "openid",
    "profile"
  ];



}
