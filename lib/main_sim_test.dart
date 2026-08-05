import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bloot/app/app.dart';
import 'package:bloot/app/app_initializer.dart';
import 'package:bloot/config/routes/app_router.dart';
import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/localization/language_manager.dart';

/// Emulator smoke-test entry point that boots the app and jumps straight into
/// the offline bot simulator so UI/card/avatar changes can be verified quickly.
void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    await AppInitializer.initialize();
    await EasyLocalization.ensureInitialized();

    runApp(
      EasyLocalization(
        supportedLocales: LanguageManager.supportedLocales,
        path: LanguageManager.translationsPath,
        fallbackLocale: LanguageManager.fallbackLocale,
        child: const BlootApp(),
      ),
    );

    // Navigate to the offline simulator once the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appRouter.go(RoutePaths.gameSim);
    });
  }, (error, stack) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('Uncaught async error: $error\n$stack');
    } else {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
  });
}
