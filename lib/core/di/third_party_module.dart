import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloot/app/app_initializer.dart';
import 'package:bloot/core/logger/app_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:app_links/app_links.dart';

@module
abstract class ThirdPartyModule {
  @preResolve
  Future<SharedPreferences> get prefs async {
    // Reuse the instance obtained during early app initialization if it
    // succeeded. This avoids a second platform-channel round-trip and
    // prevents a second failure from blocking dependency injection when
    // SharedPreferences is already known to be broken.
    final cached = AppInitializer.sharedPreferences;
    if (cached != null) return cached;

    try {
      return await SharedPreferences.getInstance();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to provide SharedPreferences via dependency injection',
        error: e,
        stackTrace: stackTrace,
        tag: LogTags.init,
      );
      rethrow;
    }
  }

  @lazySingleton
  FirebaseAuth get auth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @lazySingleton
  FirebaseStorage get storage => FirebaseStorage.instance;

  @lazySingleton
  FirebaseFunctions get functions => FirebaseFunctions.instance;

  @lazySingleton
  FirebaseMessaging get messaging => FirebaseMessaging.instance;

  @lazySingleton
  FirebaseRemoteConfig get remoteConfig => FirebaseRemoteConfig.instance;

  @lazySingleton
  FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;

  @lazySingleton
  FirebasePerformance get performance => FirebasePerformance.instance;

  @preResolve
  Future<PackageInfo> get packageInfo => PackageInfo.fromPlatform();

  @lazySingleton
  AppLinks get appLinks => AppLinks();
}
