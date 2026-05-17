import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bloot/core/style/app_colors.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/core/network/cache_helper.dart';
import 'package:bloot/core/network/cache_keys.dart';

abstract class ThemeManager {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static void initialize() {
    try {
      final cache = getIt<CacheHelper>();
      final String? savedTheme = cache.getData(key: CacheKeys.themeMode);
      if (savedTheme == 'light') {
        themeNotifier.value = ThemeMode.light;
      } else if (savedTheme == 'dark') {
        themeNotifier.value = ThemeMode.dark;
      } else {
        themeNotifier.value = ThemeMode.system;
      }
    } catch (_) {}
  }

  static Future<void> changeTheme(ThemeMode mode) async {
    themeNotifier.value = mode;
    try {
      final cache = getIt<CacheHelper>();
      if (mode == ThemeMode.light) {
        await cache.saveData(key: CacheKeys.themeMode, value: 'light');
      } else if (mode == ThemeMode.dark) {
        await cache.saveData(key: CacheKeys.themeMode, value: 'dark');
      } else {
        await cache.removeData(key: CacheKeys.themeMode);
      }
    } catch (_) {}
  }

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorManager.primary,
      primary: ColorManager.primary,
      onPrimary: Colors.white,
      surface: ColorManager.cardWhite,
      error: ColorManager.error,
    ),
    scaffoldBackgroundColor: ColorManager.softCloud,
    extensions: const [AppColors.light],
    textTheme: _buildTextTheme(isDark: false),
    appBarTheme: _buildAppBarTheme(isDark: false),
    elevatedButtonTheme: _buildElevatedButtonTheme(),
    outlinedButtonTheme: _buildOutlinedButtonTheme(),
    textButtonTheme: _buildTextButtonTheme(),
    inputDecorationTheme: _buildInputTheme(isDark: false),
    cardTheme: _buildCardTheme(isDark: false),
    dividerTheme: const DividerThemeData(
      color: ColorManager.borderSoft,
      thickness: 1,
      space: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: ColorManager.sectionGray,
      selectedColor: ColorManager.primaryLight,
      labelStyle: GoogleFonts.cairo(
        fontSize: 13,
        color: ColorManager.textSecondary,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorManager.primary,
      brightness: Brightness.dark,
      primary: ColorManager.primary,
      onPrimary: Colors.white,
      surface: ColorManager.darkSurface,
      error: ColorManager.error,
    ),
    scaffoldBackgroundColor: ColorManager.darkCanvas,
    extensions: const [AppColors.dark],
    textTheme: _buildTextTheme(isDark: true),
    appBarTheme: _buildAppBarTheme(isDark: true),
    elevatedButtonTheme: _buildElevatedButtonTheme(),
    outlinedButtonTheme: _buildOutlinedButtonTheme(),
    textButtonTheme: _buildTextButtonTheme(),
    inputDecorationTheme: _buildInputTheme(isDark: true),
    cardTheme: _buildCardTheme(isDark: true),
    dividerTheme: const DividerThemeData(
      color: ColorManager.darkBorderSoft,
      thickness: 1,
      space: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: ColorManager.darkSectionGray,
      selectedColor: ColorManager.darkPrimaryLight,
      labelStyle: GoogleFonts.cairo(
        fontSize: 13,
        color: ColorManager.darkTextSecondary,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
    ),
  );

  static TextTheme _buildTextTheme({required bool isDark}) {
    final textColor =
        isDark ? ColorManager.darkTextPrimary : ColorManager.textPrimary;
    final textSecondary =
        isDark ? ColorManager.darkTextSecondary : ColorManager.textSecondary;
    final textMuted =
        isDark ? ColorManager.darkTextMuted : ColorManager.textMuted;

    return TextTheme(
      displayLarge: GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.3,
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.3,
      ),
      displaySmall: GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
      ),
      headlineLarge: GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMuted,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      labelMedium: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      labelSmall: GoogleFonts.cairo(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: textMuted,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme({required bool isDark}) {
    return AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      backgroundColor:
          isDark ? ColorManager.darkCanvas : ColorManager.softCloud,
      foregroundColor:
          isDark ? ColorManager.darkTextPrimary : ColorManager.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color:
            isDark ? ColorManager.darkTextPrimary : ColorManager.textPrimary,
      ),
      iconTheme: IconThemeData(
        color:
            isDark ? ColorManager.darkTextPrimary : ColorManager.textPrimary,
        size: 24,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorManager.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        elevation: 2,
        shadowColor: ColorManager.primaryGlow,
        textStyle:
            GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorManager.primary,
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: ColorManager.primary),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        textStyle:
            GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ColorManager.primary,
        textStyle:
            GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  static InputDecorationTheme _buildInputTheme({required bool isDark}) {
    final bgColor =
        isDark ? ColorManager.darkSectionGray : ColorManager.sectionGray;
    final hintColor =
        isDark ? ColorManager.darkTextMuted : ColorManager.textPlaceholder;
    final borderColor =
        isDark ? ColorManager.darkBorderSoft : ColorManager.borderSoft;

    return InputDecorationTheme(
      filled: true,
      fillColor: bgColor,
      hintStyle: GoogleFonts.cairo(color: hintColor, fontSize: 14),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(
          color: ColorManager.primary,
          width: 1.5,
        ),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: ColorManager.error),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(
          color: ColorManager.error,
          width: 1.5,
        ),
      ),
    );
  }

  static CardThemeData _buildCardTheme({required bool isDark}) {
    return CardThemeData(
      color: isDark ? ColorManager.darkSurface : ColorManager.cardWhite,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        side: BorderSide(
          color: isDark
              ? ColorManager.darkBorderSubtle
              : ColorManager.borderSoft,
        ),
      ),
    );
  }
}
