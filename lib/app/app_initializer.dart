import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_app_distribution/firebase_app_distribution.dart'
    as firebase_app_distribution;
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
  static SharedPreferences? _sharedPreferences;
  static const String _kAppDistSignInAttemptKey = 'app_dist_signin_attempt_ms';

  /// Cached [SharedPreferences] instance from the early initialization.
  /// This is reused by the dependency injection module so we do not call
  /// [SharedPreferences.getInstance] twice when the first attempt succeeded.
  static SharedPreferences? get sharedPreferences => _sharedPreferences;

  static Future<void> initialize() async {
    AppLogger.info('Starting initialization...', tag: LogTags.init);

    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      onboardingCompleted =
          _sharedPreferences!.getBool(CacheKeys.onboardingComplete) ?? false;
      isGuest = _sharedPreferences!.getBool(CacheKeys.isGuest) ?? false;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize SharedPreferences; continuing with defaults',
        error: e,
        stackTrace: stackTrace,
        tag: LogTags.init,
      );
      onboardingCompleted = false;
      isGuest = false;
    }

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
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(
      !kDebugMode,
    );

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
      // Always enable Crashlytics so QA testers on emulators and debug
      // builds also report crashes and caught errors to the Firebase console.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      AppLogger.info('Crashlytics collection enabled', tag: LogTags.init);
    } catch (e) {
      AppLogger.error('Failed to initialize Crashlytics', error: e);
    }
  }

  static Future<void> _initializeGoogleSignIn() async {
    try {
      if (kIsWeb) return;
      // The web OAuth client ID is not a secret (it is bundled in every
      // client app and also lives in env/endpoints.json), so it is safe as a
      // default. google_sign_in v7 on Android fails immediately with
      // MISSING_SERVER_CLIENT_ID when this is empty, so the defaultValue
      // guarantees release builds always have it even if the dart-define is
      // forgotten. The build scripts (fastlane, qa_pipeline.ps1) also pass
      // --dart-define=GOOGLE_SERVER_CLIENT_ID explicitly.
      const googleClientId = String.fromEnvironment(
        'GOOGLE_SERVER_CLIENT_ID',
        defaultValue:
            '738592764893-mkmgsfs9l833olurohk5ct2p9e1q0mir.apps.googleusercontent.com',
      );
      await GoogleSignIn.instance.initialize(
        serverClientId: googleClientId.isNotEmpty ? googleClientId : null,
      );
      if (googleClientId.isEmpty) {
        AppLogger.warning(
          'GOOGLE_SERVER_CLIENT_ID missing from environment. Google Sign-In might fail on some platforms.',
          tag: LogTags.init,
        );
        if (!kDebugMode) {
          try {
            FirebaseCrashlytics.instance.recordError(
              StateError('GOOGLE_SERVER_CLIENT_ID empty at build time'),
              null,
              reason: 'Google Sign-In will fail on Android',
            );
          } catch (_) {}
        }
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
    if (kDebugMode) return; // Skip on debug/emulator to avoid Chrome redirect
    if (_didInitAppDistribution) return;
    _didInitAppDistribution = true;

    Future.microtask(() async {
      try {
        AppLogger.info('Checking tester sign-in...', tag: LogTags.init);
        final bool isTesterSignedIn = await firebase_app_distribution
            .isTesterSignedIn();
        AppLogger.info('isTesterSignedIn=$isTesterSignedIn', tag: LogTags.init);

        if (!isTesterSignedIn) {
          final prefs =
              _sharedPreferences ?? (await SharedPreferences.getInstance());
          final lastAttempt = prefs.getInt(_kAppDistSignInAttemptKey) ?? 0;
          final now = DateTime.now().millisecondsSinceEpoch;

          // Prevent re-triggering sign-in if the process was killed while
          // Chrome was in the foreground (common cause of redirect loops).
          if (now - lastAttempt < 60000) {
            AppLogger.info(
              'Skipping signInTester: recent attempt detected',
              tag: LogTags.init,
            );
            // We are not signed in and we must not prompt again so soon.
            return;
          }

          await prefs.setInt(_kAppDistSignInAttemptKey, now);
          AppLogger.info('Calling signInTester...', tag: LogTags.init);
          await firebase_app_distribution.signInTester();
          // Do NOT clear the timestamp here. If the OS kills this process
          // while the browser is in the foreground, a fresh process handling
          // the redirect would otherwise see no recent attempt and call
          // signInTester again, creating the browser<->app loop.
          AppLogger.info('Tester signed in', tag: LogTags.init);
        }

        // Re-check sign-in state before enabling features that can themselves
        // prompt for sign-in (e.g., updateIfNewReleaseAvailable).
        final bool signedInNow = await firebase_app_distribution
            .isTesterSignedIn();
        if (!signedInNow) {
          AppLogger.warning(
            'Tester sign-in not confirmed; skipping feedback/updates',
            tag: LogTags.init,
          );
          return;
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
        AppLogger.info(
          'App Distribution initialized for tester',
          tag: LogTags.init,
        );
      } catch (e) {
        // App Distribution sign-in can fail when the tester cancels the
        // browser flow or on emulators without Play Services. This is not
        // a real error — log as warning to avoid polluting Crashlytics.
        AppLogger.warning(
          'App Distribution init skipped: $e',
          tag: LogTags.init,
        );
      }
    });
  }
}
