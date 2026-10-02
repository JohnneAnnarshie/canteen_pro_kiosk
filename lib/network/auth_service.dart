import 'dart:developer';

import 'package:flutter_appauth/flutter_appauth.dart';

import '../models/auth.dart';

class AuthService {
  AuthService({
    required this.clientId,
    required this.redirectUrl,
    required this.discoveryUrl,
    required this.postLogoutRedirect,
    required this.scopes,
    required this.clientSecret,
    required this.idToken,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.endSessionEndpoint,
  });

  FlutterAppAuth appAuth = const FlutterAppAuth();
  final String clientId;
  final String redirectUrl;
  final String discoveryUrl;
  final String postLogoutRedirect;
  final List<String> scopes;
  final String clientSecret;
  final String idToken;
  final String authorizationEndpoint;
  final String tokenEndpoint;
  final String endSessionEndpoint;

  // Login method
  Future<Map<String, Auth?>> login() async {
    try {
      final result = await appAuth.authorizeAndExchangeCode(
          AuthorizationTokenRequest(
              clientId, redirectUrl,
              clientSecret: clientSecret,
              //discoveryUrl: discoveryUrl,
              serviceConfiguration: AuthorizationServiceConfiguration(
                  authorizationEndpoint: authorizationEndpoint,
                  tokenEndpoint: tokenEndpoint,
                  endSessionEndpoint: endSessionEndpoint
              ),
              scopes: scopes,
              promptValues: ['login']
        //promptValues: ['login']
      ));
      log(name: 'idToken', result.idToken ?? 'ID token not available');
      log(name: 'accessToken', result.accessToken ?? 'Access token not available');
      log(name:'refreshToken' ,result.refreshToken ?? 'Refresh token not available');
      log(name:'accessTokenExpirationDateTime' ,result.accessTokenExpirationDateTime!.toString());
      if (result != null) {
        final auth = Auth(result.accessToken!, result.idToken!, result.tokenType!,
            result.refreshToken!, result.accessTokenExpirationDateTime!);
        return {'': auth};
      }
      return {'An error occurred': null};
    } catch (e) {
      if (e.toString().toLowerCase().contains('user cancelled flow')) {
        return {'User cancelled login': null};
      }
      return {e.toString(): null};
    }
  }

  // Refresh method
  Future<Auth?> refresh(String refreshToken) async {
    try {
      final TokenResponse? result = await appAuth.token(
        TokenRequest(
          clientId,
          redirectUrl,
          clientSecret: clientSecret,
          //discoveryUrl: discoveryUrl,
          refreshToken: refreshToken,
          grantType: 'refresh_token',
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: authorizationEndpoint,
            tokenEndpoint: tokenEndpoint,
            endSessionEndpoint: endSessionEndpoint
          ),
          scopes: scopes,
        ),
      );
      if (result == null) {
        return null;
      }
      return Auth(
        result.accessToken!,
        result.idToken!,
        result.tokenType!,
        result.refreshToken!,
        result.accessTokenExpirationDateTime!,
      );
    } catch (e) {
      log(e.toString(), name: 'refresh Error', stackTrace: StackTrace.current);
      return null;
    }
  }

  logout() async {
    final result = await appAuth.endSession(
        EndSessionRequest(
            idTokenHint: idToken,
            postLogoutRedirectUrl: postLogoutRedirect,
            serviceConfiguration: AuthorizationServiceConfiguration(
                authorizationEndpoint: authorizationEndpoint,
                tokenEndpoint: tokenEndpoint,
                endSessionEndpoint: endSessionEndpoint
        )
    )
    );
  }
}
