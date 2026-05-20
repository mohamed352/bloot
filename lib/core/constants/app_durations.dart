/// Standard animation durations used across the Bloot app.
abstract class AppDurations {
  AppDurations._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration snackBar = Duration(seconds: 3);
  static const Duration splash = Duration(seconds: 2);
}
