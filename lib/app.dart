import 'package:canteen_pro/features/admin/configuration_proivder.dart';
import 'package:canteen_pro/services/connectivity_service.dart';
import 'package:canteen_pro/services/palm_vein_plugin/palm_vein_service.dart';
import 'package:canteen_pro/utils/permissions_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/device_setup/app_mode_selection.dart';
import 'features/device_setup/device_provider.dart';
import 'features/landing/auth_provider.dart';
import 'features/landing/get_started_provider.dart';
import 'services/text_to_speech_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class CanteenApp extends ConsumerStatefulWidget {
  const CanteenApp({super.key});


  @override
  ConsumerState<CanteenApp> createState() => _CanteenAppState();
}

class _CanteenAppState extends ConsumerState<CanteenApp> with WidgetsBindingObserver {

  @override
  void initState() {
    PalmVeinService().initialize();
    TextToSpeechService().initialize();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() async {

      ref.read(getStartedState.notifier).getIsGetStarted();
      ref.read(configurationState.notifier).loadConfiguration();
      ref.read(deviceSetUpProvider.notifier).initialize();
      ref.read(connectivityProvider.notifier).initConnectivityStream();
      ref.read(appModeStateProvider.notifier).initialize();
      ref.read(currentAuthProvider.notifier).initialize();


      await PermissionsHandler.requestCameraPermissions();
      await PermissionsHandler.requestPhotoPermissions();
      await PermissionsHandler.requestMicrophonePermissions();
    });
    super.initState();
  }

  @override
  void dispose() {
    PalmVeinService().dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      PalmVeinService().initialize();
      try {
        TextToSpeechService().initialize();
      } catch (_) {}
    }
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      try {
        PalmVeinService().dispose();
        TextToSpeechService().initialize();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Canteen Pro',
      theme: AppTheme.lightTheme.copyWith(
        textTheme: createTextTheme(context, 'Outfit', 'Outfit').apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        )
      ),
      themeMode: ThemeMode.light,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: true,
    );
  }
}
