import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloot/core/logger/app_logger.dart';

abstract class AppRedirect {
  static String? globalRedirect(BuildContext context, GoRouterState state) {
    final String currentPath = state.matchedLocation;
    AppLogger.debug('Navigating to: $currentPath', tag: LogTags.router);
    return null;
  }
}
