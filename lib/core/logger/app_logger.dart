import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

export 'log_config.dart';

abstract class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5, lineLength: 80),
  );

  static void debug(String message, {String? tag}) {
    _logger.d(_format(message, tag));
  }

  static void info(String message, {String? tag}) {
    _logger.i(_format(message, tag));
  }

  static void warning(String message, {String? tag}) {
    _logger.w(_format(message, tag));
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(_format(message, tag), error: error, stackTrace: stackTrace);
    _recordCrashlytics(
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      fatal: false,
    );
  }

  static void fatal(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.f(_format(message, tag), error: error, stackTrace: stackTrace);
    _recordCrashlytics(
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      fatal: true,
    );
  }

  static String _format(String message, String? tag) {
    if (tag != null) return '[$tag] $message';
    return message;
  }

  static void _recordCrashlytics(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    required bool fatal,
  }) {
    if (kDebugMode && error == null) return;
    try {
      final exception = error ?? Exception(_format(message, tag));
      if (fatal) {
        FirebaseCrashlytics.instance.recordError(
          exception,
          stackTrace,
          fatal: true,
        );
      } else {
        FirebaseCrashlytics.instance.recordError(exception, stackTrace);
      }
      FirebaseCrashlytics.instance.log(_format(message, tag));
    } catch (_) {
      // Crashlytics not initialized yet — ignore.
    }
  }

  /// Sets the current user's identifier for Crashlytics reports.
  static void setUserId(String? uid) {
    try {
      FirebaseCrashlytics.instance.setUserIdentifier(uid ?? '');
    } catch (_) {}
  }

  /// Sets a custom key for Crashlytics reports, e.g. roomId, gameId, streamId.
  static void setCustomKey(String key, String? value) {
    try {
      FirebaseCrashlytics.instance.setCustomKey(key, value ?? 'null');
    } catch (_) {}
  }
}
