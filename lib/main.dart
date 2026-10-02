import 'package:canteen_pro/app.dart';
import 'package:canteen_pro/services/notfifcations_service.dart';
import 'package:canteen_pro/services/prefs_repo.dart';
import 'package:canteen_pro/utils/permissions_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'network/repos/network_config.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable runtime fetching for Google Fonts since fonts are bundled in assets
  GoogleFonts.config.allowRuntimeFetching = false;

  tz.initializeTimeZones();
  await PrefsRepo().initialize();
  await NetworkConfig().initialize();
  await NotificationService.initialize();

  //await BackgroundTasksService.instance.startShiftsDeletion();
  runApp(const ProviderScope(child: CanteenApp()));
}
