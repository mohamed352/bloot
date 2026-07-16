import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bloot/app/app.dart';
import 'package:bloot/app/app_initializer.dart';
import 'package:bloot/core/localization/language_manager.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

      await AppInitializer.initialize();
      await EasyLocalization.ensureInitialized();

      runApp(
        EasyLocalization(
          supportedLocales: LanguageManager.supportedLocales,
          path: LanguageManager.translationsPath,
          fallbackLocale: LanguageManager.fallbackLocale,
          startLocale: LanguageManager.arabic,
          child: const BlootApp(),
        ),
      );
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      if (kDebugMode) {
        // ignore: avoid_print
        print('Uncaught async error: $error\n$stack');
      }
    },
  );
}
