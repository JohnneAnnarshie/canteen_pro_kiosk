import 'package:canteen_pro/features/landing/landing_screen.dart';
import 'package:canteen_pro/features/member_auth/member_auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/landing/auth_provider.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  void initState() {
    super.initState();
    //_initConnectivityStream();

  }

  // void _initConnectivityStream() {
  //   Connectivity().onConnectivityChanged.listen((result) {
  //     if (result.contains(ConnectivityResult.none)) {
  //       ref.read(connectivityProvider.notifier).setConnectivity(false);
  //     } else {
  //       ref.read(connectivityProvider.notifier).setConnectivity(true);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer( builder: (context, ref, child) {
      final isAuthenticated = ref.watch(
        currentAuthProvider.select((state) => state != null),
      );
      if (isAuthenticated) {
        return const MemberAuthScreen();
      } else {
        return const LandingScreen();
      }
    }
    );
  }
}
