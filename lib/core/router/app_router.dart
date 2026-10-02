import 'dart:developer';

import 'package:canteen_pro/features/admin/admin_screen.dart';
import 'package:canteen_pro/features/device_setup/device_verification_screen.dart';
import 'package:canteen_pro/features/landing/landing_screen.dart';
import 'package:canteen_pro/features/member_auth/member_auth_screen.dart';
import 'package:canteen_pro/features/pre_order/pre_order_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth_gate.dart';
import '../../features/admin/configuration_proivder.dart';
import '../../features/device_setup/app_mode_selection.dart';
import '../../features/device_setup/device_provider.dart';
import '../../features/device_setup/device_setup_screen.dart';
import '../../features/enrollment/enrollment_screen.dart';
import '../../features/landing/get_started_provider.dart';
import '../../features/pre_order/pre_order_confirm_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final deviceSetup = ref.watch(deviceSetUpProvider);
  final isGetStarted = ref.watch(getStartedState);
  final isDeviceVerified = deviceSetup?.status == true;
  final canteenConfig = ref.watch(configurationState);

  return GoRouter(
    initialLocation: AppRoute.memberAuth.path,
    redirect: (context, state) {
      if (!isGetStarted) {
        return AppRoute.getStarted.path;
      }
      if (deviceSetup == null) {
        return AppRoute.deviceSetup.path;
      }
      if (!isDeviceVerified) {
        return AppRoute.deviceVerification.path;
      }
      if (canteenConfig.canteenSetting == null) {
        return AppRoute.admin.path;
      }
      if (canteenConfig.mealServeTime == null) {
        return AppRoute.admin.path;
      }


      return null;
    },
    routes: [
      GoRoute(
        name: AppRoute.getStarted.name,
        path: AppRoute.getStarted.path,
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        name: AppRoute.deviceSetup.name,
        path: AppRoute.deviceSetup.path,
        builder: (context, state) => const DeviceSetupScreen(),
      ),
      GoRoute(
        name: AppRoute.deviceVerification.name,
        path: AppRoute.deviceVerification.path,
        builder: (context, state) => const DeviceVerificationScreen(),
      ),
      GoRoute(
        name: AppRoute.userEnrollment.name,
        path: AppRoute.userEnrollment.path,
        builder: (context, state) => const EnrollmentScreen(),
      ),
      GoRoute(
        name: AppRoute.memberAuth.name,
        path: AppRoute.memberAuth.path,
        builder: (context, state) => const MemberAuthScreen(),
      ),
      GoRoute(
        name: AppRoute.preOrder.name,
        path: AppRoute.preOrder.path,
        builder: (context, state) => const PreOrderScreen(),
      ),
      GoRoute(
        name: AppRoute.preOrderConfirm.name,
        path: AppRoute.preOrderConfirm.path,
        builder: (context, state) => const PreOrderConfirmScreen(),
      ),
      GoRoute(
        name: AppRoute.authCheck.name,
        path: AppRoute.authCheck.path,
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        name: AppRoute.admin.name,
        path: AppRoute.admin.path,
        builder: (context, state) => const AdminScreen(),
      ),
    ],
  );
});

enum AppRoute {
  memberAuth(path: '/member/auth'),
  getStarted(path: '/get_started'),
  deviceSetup(path: '/device/setup'),
  deviceVerification(path: '/device/verification'),
  userEnrollment(path: '/user/enrollment'),
  preOrder(path: '/member/preorder'),
  preOrderConfirm(path: '/member/preorder/confirm'),
  admin(path: '/admin'),
  authCheck(path: '/auth/check');


  final String path;
  const AppRoute({required this.path});

}
