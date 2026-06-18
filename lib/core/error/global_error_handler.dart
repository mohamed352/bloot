import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:bloot/core/logger/app_logger.dart';

abstract class GlobalErrorHandler {
  static void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      AppLogger.error(
        'Flutter error: ${details.exceptionAsString()}',
        tag: LogTags.lifecycle,
        error: details.exception,
        stackTrace: details.stack,
      );
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordFlutterError(details);
      }
    };
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      AppLogger.fatal(
        'Platform error',
        tag: LogTags.lifecycle,
        error: error,
        stackTrace: stack,
      );
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
      return true;
    };
  }
}
