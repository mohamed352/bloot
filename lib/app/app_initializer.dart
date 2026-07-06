import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/core/error/global_error_handler.dart';
import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/core/network/cache_helper.dart';
import 'package:bloot/core/network/cache_keys.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/config/app_check_config.dart';
import 'package:bloot/core/services/audio_service.dart';
import 'package:bloot/core/services/notification_service.dart';
import 'package:bloot/core/services/remote_config_service.dart';
import 'package:bloot/firebase_options.dart';

abstract class AppInitializer {
  static bool onboardingCompleted = false;
  static bool isGuest = false;

  static Future<void> initialize() async {
    AppLogger.info('Starting initialization...', tag: LogTags.init);

    final prefs = await SharedPreferences.getInstance();
    onboardingCompleted = prefs.getBool(CacheKeys.onboardingComplete) ?? false;
    isGuest = prefs.getBool(CacheKeys.isGuest) ?? false;

    GlobalErrorHandler.initialize();
    AppLogger.info('Error handlers installed', tag: LogTags.init);

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppLogger.info('Firebase initialized', tag: LogTags.init);
    } else {
      AppLogger.info(
        'Firebase already initialized, skipping duplicate init',
        tag: LogTags.init,
      );
    }

    // Activate Firebase App Check to protect callable functions and Firestore.
    await _activateAppCheck();

    // Initialize Crashlytics in non-debug builds.
    await _initializeCrashlytics();

    // Initialize Performance Monitoring.
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(!kDebugMode);

    // Pre-initialize Google Sign-In so the account picker is ready on login.
    await _initializeGoogleSignIn();

    await configureDependencies();
    AppLogger.info('DI configured', tag: LogTags.init);

    // Initialize Remote Config with a short timeout so a slow network does not
    // block app launch.
    await getIt<RemoteConfigService>().initialize().timeout(
      const Duration(seconds: 5),
      onTimeout: () => AppLogger.warning(
        'Remote Config initialization timed out; continuing with defaults',
        tag: LogTags.init,
      ),
    );

    // Initialize push notifications. FCM token retrieval can be slow on test
    // devices without Play Services, so don't let it block app launch.
    await getIt<NotificationService>().initialize().timeout(
      const Duration(seconds: 5),
      onTimeout: () => AppLogger.warning(
        'Notification service initialization timed out; continuing without FCM',
        tag: LogTags.init,
      ),
    );
    AppLogger.info('Notification service initialized', tag: LogTags.init);

    // Initialize audio service
    await getIt<AudioService>().initialize();
    AppLogger.info('Audio service initialized', tag: LogTags.init);

    // Crash recovery: clean up orphaned Agora channel
    await _cleanupOrphanedAgoraChannel();

    AppLogger.info('Initialization complete', tag: LogTags.init);
  }

  static Future<void> _activateAppCheck() async {
    try {
      final appCheck = FirebaseAppCheck.instance;
      if (kDebugMode) {
        await appCheck.activate(
          providerAndroid: const AndroidDebugProvider(),
          providerApple: const AppleDebugProvider(),
          providerWeb: ReCaptchaV3Provider(AppCheckConfig.recaptchaSiteKey),
        );
      } else {
        await appCheck.activate(
          providerApple: const AppleAppAttestProvider(),
          providerWeb: ReCaptchaV3Provider(AppCheckConfig.recaptchaSiteKey),
        );
      }
      AppLogger.info('App Check activated', tag: LogTags.init);
    } catch (e) {
      AppLogger.error('Failed to activate App Check', error: e);
    }
  }

  static Future<void> _initializeCrashlytics() async {
    try {
      if (kDebugMode) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      } else {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      }
    } catch (e) {
      AppLogger.error('Failed to initialize Crashlytics', error: e);
    }
  }

  static Future<void> _initializeGoogleSignIn() async {
    try {
      if (kIsWeb) return;
      const googleClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
      await GoogleSignIn.instance.initialize(
        serverClientId: googleClientId.isNotEmpty ? googleClientId : null,
      );
      if (googleClientId.isEmpty) {
        AppLogger.warning(
          'GOOGLE_SERVER_CLIENT_ID missing from environment. Google Sign-In might fail on some platforms.',
          tag: LogTags.init,
        );
      } else {
        AppLogger.info('Google Sign-In initialized', tag: LogTags.init);
      }
    } catch (e) {
      AppLogger.error(
        'Ignored Google Sign-In initialization error: $e',
        tag: LogTags.init,
      );
    }
  }

  static Future<void> _cleanupOrphanedAgoraChannel() async {
    try {
      final cacheHelper = getIt<CacheHelper>();
      final channelId = cacheHelper.getData(key: CacheKeys.activeChannelId);
      if (channelId != null && channelId.isNotEmpty) {
        AppLogger.warning(
          'Found orphaned Agora channel: $channelId. Cleaning up.',
          tag: LogTags.init,
        );
        final agoraService = getIt<AgoraService>();
        await agoraService.leaveChannel();
        await cacheHelper.removeData(key: CacheKeys.activeChannelId);
      }
    } catch (e) {
      AppLogger.error('Failed to cleanup orphaned Agora channel', error: e);
    }
  }
}
