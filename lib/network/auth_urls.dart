
import 'api_urls.dart';

const clientSecret = 'UqvZ6358Et';
const clientId = 'time_trakker_log';
const String redirectUrl = 'com.persol.timetrakkerlogistics:/';
const postLogoutRedirectUrl =
    'com.persol.timetrakkerlogistics:/'; //com.persol.timetrakkerlogistics:/
const scopes = [
  "personax_modular_api",
  "offline_access",
  "email",
  "openid",
  "profile"
];

final discoveryUrl = '$idpBaseUrl.well-known/openid-configuration';
final authEndpoint = '${idpBaseUrl}connect/authorize';
final tokenEndpoint = '${idpBaseUrl}connect/token';
final endSessionUrl = '${idpBaseUrl}connect/endsession';
final String userInfoUrl = '${idpBaseUrl}connect/userinfo';
