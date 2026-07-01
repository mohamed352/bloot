import 'package:flutter/foundation.dart';

/// Decides whether the Flutter app should talk to the local Firebase Emulator
/// Suite and which host to use.
///
/// This is only enabled in debug builds running outside the browser. On
/// Android emulators the host must be `10.0.2.2` so the device can reach the
/// laptop's localhost; on all other platforms `localhost` works.
abstract class FirebaseEmulatorConfig {
  static const bool enabled = kDebugMode && !kIsWeb;
  static String get host => _isAndroidEmulator ? '10.0.2.2' : 'localhost';
  static bool get _isAndroidEmulator =>
      defaultTargetPlatform == TargetPlatform.android && !kIsWeb;

  static const int firestorePort = 8080;
  static const int authPort = 9099;
  static const int functionsPort = 5001;
  static const int storagePort = 9199;
}
