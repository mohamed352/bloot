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

      // Never let an initialization failure strand the app on the native
      // splash screen: always call runApp, even in a degraded state.
      // (Play rejected a build for "app doesn't open or load" because any
      // throw here skipped runApp and left the splash up forever.)
      try {
        await AppInitializer.initialize();
      } catch (error, stack) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('App initialization failed; starting degraded: $error\n$stack');
        }
        try {
          FirebaseCrashlytics.instance.recordError(error, stack);
        } catch (_) {
          // Crashlytics itself may be unavailable if Firebase init failed.
        }
      }

      try {
        await EasyLocalization.ensureInitialized();
      } catch (error, stack) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('Localization init failed; using fallback locale: $error');
        }
        try {
          FirebaseCrashlytics.instance.recordError(error, stack);
        } catch (_) {}
      }

      runApp(
        EasyLocalization(
          supportedLocales: LanguageManager.supportedLocales,
          path: LanguageManager.translationsPath,
          fallbackLocale: LanguageManager.fallbackLocale,
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
