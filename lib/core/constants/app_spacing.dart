/// Design-system spacing values used across the Bloot app.
///
/// All values are logical pixels; apply via [EdgeInsetsDirectional] or
/// [SizedBox] as appropriate.
abstract class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double section = 48;

  // Screen padding
  static const double screenHorizontal = 16;
  static const double screenVertical = 16;

  // Card padding
  static const double cardInternal = 16;
  static const double cardExternal = 12;

  // Button
  static const double buttonHeight = 52;
  static const double buttonHeightSm = 44;
  static const double buttonHorizontalPadding = 24;

  // Input
  static const double inputHeight = 56;
  static const double inputHeightSm = 44;

  // Navigation
  static const double bottomNavHeight = 64;
  static const double topBarHeight = 56;
}
