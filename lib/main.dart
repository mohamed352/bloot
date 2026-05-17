import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bloot/app/app.dart';
import 'package:bloot/app/app_initializer.dart';
import 'package:bloot/core/localization/language_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
}
