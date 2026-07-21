import 'package:firebase_app_distribution_platform_interface/firebase_app_distribution_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The iOS implementation of [FirebaseAppDistributionPlatform].
class FirebaseAppDistributionIOS extends FirebaseAppDistributionPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('firebase_app_distribution_ios');

  /// The event channel used to receive download progress updates.
  @visibleForTesting
  final eventChannel = const EventChannel(
    'firebase_app_distribution_ios/download_progress',
  );

  /// Registers this class as the default instance of [FirebaseAppDistributionPlatform]
  static void registerWith() {
    FirebaseAppDistributionPlatform.instance = FirebaseAppDistributionIOS();
  }

  @override
  Future<void> updateIfNewReleaseAvailable() async {
    return;
  }

  @override
  Future<AppDistributionRelease?> checkForNewRelease() async {
    return null;
  }

  @override
  Future<void> updateApp() async {
    return;
  }

  @override
  Stream<AppDistributionDownloadProgress> get downloadProgress {
    return const Stream.empty();
  }

  @override
  Future<bool> isNewReleaseAvailable() async {
    return false;
  }

  @override
  Future<bool> isTesterSignedIn() async {
    return false;
  }

  @override
  Future<void> signInTester() async {
    return;
  }

  @override
  Future<void> signOutTester() async {
    return;
  }
}
