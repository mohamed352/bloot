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
  }

  static void fatal(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.f(_format(message, tag), error: error, stackTrace: stackTrace);
  }

  static String _format(String message, String? tag) {
    if (tag != null) return '[$tag] $message';
    return message;
  }
}
