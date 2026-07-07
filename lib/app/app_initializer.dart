import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_app_distribution/firebase_app_distribution.dart' as firebase_app_distribution;
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
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
import 'package:bloot/core/utils/app_distribution_helper.dart';
import 'package:bloot/firebase_options.dart';

abstract class AppInitializer {
  static bool onboardingCompleted = false;
  static bool isGuest = false;
  static bool _didInitAppDistribution = false;
  static const String _kAppDistSignInAttemptKey = 'app_dist_signin_attempt_ms';

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
    // Skip App Check activation in debug builds so testing on emulators and
    // debug devices works without registering a debug token in the Firebase
    // console. Release builds still require a valid App Check token.
    if (kDebugMode) {
      AppLogger.info(
        'App Check skipped in debug build (release builds will enforce it)',
        tag: LogTags.init,
      );
      return;
    }

    try {
      final appCheck = FirebaseAppCheck.instance;
      await appCheck.activate(
        providerApple: const AppleAppAttestProvider(),
        providerWeb: ReCaptchaV3Provider(AppCheckConfig.recaptchaSiteKey),
      );
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

  /// Initializes Firebase App Distribution for testers.
  /// Should be called after the first frame is rendered so the
  /// Flutter activity is fully in the foreground.
  static void initAppDistribution() {
    if (kIsWeb || !Platform.isAndroid) return;
    if (_didInitAppDistribution) return;
    _didInitAppDistribution = true;

    Future.microtask(() async {
      try {
        AppLogger.info('Checking tester sign-in...', tag: LogTags.init);
        final bool isTesterSignedIn = await firebase_app_distribution.isTesterSignedIn();
        AppLogger.info('isTesterSignedIn=$isTesterSignedIn', tag: LogTags.init);

        if (!isTesterSignedIn) {
          final prefs = await SharedPreferences.getInstance();
          final lastAttempt = prefs.getInt(_kAppDistSignInAttemptKey) ?? 0;
          final now = DateTime.now().millisecondsSinceEpoch;

          // Prevent re-triggering sign-in if the process was killed while
          // Chrome was in the foreground (common cause of redirect loops).
          if (now - lastAttempt < 60000) {
            AppLogger.info(
              'Skipping signInTester: recent attempt detected',
              tag: LogTags.init,
            );
          } else {
            await prefs.setInt(_kAppDistSignInAttemptKey, now);
            AppLogger.info('Calling signInTester...', tag: LogTags.init);
            await firebase_app_distribution.signInTester();
            // Clear attempt timestamp on success.
            await prefs.remove(_kAppDistSignInAttemptKey);
            AppLogger.info('Tester signed in', tag: LogTags.init);
          }
        }

        // Show the persistent feedback notification now that the tester
        // is authenticated (onCreate may have failed because sign-in
        // hadn't completed yet on the first run).
        final notificationStatus = await Permission.notification.request();
        if (notificationStatus.isGranted) {
          await AppDistributionHelper.showFeedbackNotification();
        } else {
          AppLogger.warning(
            'Notification permission denied — feedback notification not shown',
            tag: LogTags.init,
          );
        }

        await firebase_app_distribution.updateIfNewReleaseAvailable();
        AppLogger.info('App Distribution initialized for tester', tag: LogTags.init);
      } catch (e, stackTrace) {
        AppLogger.error(
          'App Distribution init failed',
          tag: LogTags.init,
          error: e,
          stackTrace: stackTrace,
        );
      }
    });
  }
}
