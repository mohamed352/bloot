import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/core/error/global_error_handler.dart';
import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/core/network/cache_keys.dart';
import 'package:bloot/core/style/theme_manager.dart';

// Uncomment after running `flutterfire configure`:
// import 'package:firebase_core/firebase_core.dart';
// import 'package:bloot/firebase_options.dart';

abstract class AppInitializer {
  static bool onboardingCompleted = false;
  static bool isGuest = false;

  static Future<void> initialize() async {
    AppLogger.info('Starting initialization...', tag: LogTags.init);

    final prefs = await SharedPreferences.getInstance();
    onboardingCompleted =
        prefs.getBool(CacheKeys.onboardingComplete) ?? false;
    isGuest = prefs.getBool(CacheKeys.isGuest) ?? false;

    GlobalErrorHandler.initialize();
    AppLogger.info('Error handlers installed', tag: LogTags.init);

    await configureDependencies();
    AppLogger.info('DI configured', tag: LogTags.init);

    // TODO: Uncomment after running `flutterfire configure`
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );

    ThemeManager.initialize();

    AppLogger.info('Initialization complete', tag: LogTags.init);
  }
}
