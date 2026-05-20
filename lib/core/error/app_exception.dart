import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:bloot/generated/locale_keys.g.dart';

class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.error,
    this.stackTrace,
  });

  factory AppException.from(Object error, [StackTrace? stack]) {
    if (error is TimeoutException) {
      return AppException(
        message: LocaleKeys.errorTimeout.tr(),
        code: 'timeout',
        error: error,
        stackTrace: stack,
      );
    }
    return AppException(
      message: LocaleKeys.errorUnknown.tr(),
      code: 'unknown',
      error: error,
      stackTrace: stack,
    );
  }

  factory AppException.fromFirebase(Object error, [StackTrace? stack]) {
    final code = error is FirebaseException ? error.code : null;
    String message = LocaleKeys.errorServer.tr();

    switch (code) {
      case 'user-not-found':
      case 'invalid-credential':
        message = LocaleKeys.errorInvalidCredential.tr();
        break;
      case 'email-already-in-use':
        message = LocaleKeys.errorEmailInUse.tr();
        break;
      case 'network-request-failed':
        message = LocaleKeys.errorNetwork.tr();
        break;
      case 'too-many-requests':
        message = LocaleKeys.errorTooManyRequests.tr();
        break;
      case 'permission-denied':
        message = LocaleKeys.errorPermissionDenied.tr();
        break;
      default:
        message = error.toString();
    }

    return AppException(
      message: message,
      code: code,
      error: error,
      stackTrace: stack,
    );
  }

  final String message;
  final String? code;
  final Object? error;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException($code): $message';
}
