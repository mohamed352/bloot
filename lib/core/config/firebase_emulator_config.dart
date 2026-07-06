import 'package:flutter/foundation.dart';

/// Deprecated: the Bloot app now always connects to the real Firebase project.
///
/// This class is kept as a no-op so existing imports do not break. All
/// emulator-related wiring has been removed from the app.
@Deprecated('Emulator support has been removed; app uses production Firebase.')
abstract class FirebaseEmulatorConfig {
  static const bool enabled = false;
  static String get host => _isAndroidEmulator ? '10.0.2.2' : 'localhost';
  static bool get _isAndroidEmulator =>
      defaultTargetPlatform == TargetPlatform.android && !kIsWeb;

  static const int firestorePort = 8080;
  static const int authPort = 9099;
  static const int functionsPort = 5001;
  static const int storagePort = 9199;
}
