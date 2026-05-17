import 'dart:ui';

abstract class LanguageManager {
  static const Locale arabic = Locale('ar');
  static const Locale english = Locale('en');

  static const Locale fallbackLocale = arabic;

  static const List<Locale> supportedLocales = [arabic, english];

  static const String translationsPath = 'assets/translations';
}
