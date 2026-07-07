import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/core/services/remote_config_service.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_state.dart';

/// Global redirect guard that uses the [AuthCubit] as the single source of truth
/// for authentication and profile-completion state, and enforces operational
/// gates from Remote Config (maintenance / force update).
abstract class AppRedirect {
  static String? globalRedirect(BuildContext context, GoRouterState state) {
    final String currentPath = state.matchedLocation;
    AppLogger.debug('Navigating to: $currentPath', tag: LogTags.router);

    // Operational gates are evaluated first.
    final operationalRedirect = _operationalRedirect(currentPath);
    if (operationalRedirect != null) return operationalRedirect;

    final authState = context.read<AuthCubit>().state;
    final isAuthenticated =
        authState is AuthAuthenticated || authState is AuthProfileRequired;
    final isProfileComplete = authState is AuthAuthenticated;

    // Routes that are always reachable, even when unauthenticated.
    final isPublicRoute = [
      RoutePaths.splash,
      RoutePaths.welcome,
      RoutePaths.login,
      RoutePaths.terms,
      RoutePaths.privacy,
      RoutePaths.forceUpdate,
      RoutePaths.maintenance,
      RoutePaths.offline,
      RoutePaths.gameSim,
    ].contains(currentPath);

    // Pure authentication flow routes (welcome → login).
    final isAuthRoute = [
      RoutePaths.welcome,
      RoutePaths.login,
    ].contains(currentPath);

    // Authenticated users that already have a profile should not re-enter auth.
    if (isProfileComplete && isAuthRoute) {
      AppLogger.debug(
        'Authenticated complete user on auth route → home',
        tag: LogTags.router,
      );
      return RoutePaths.home;
    }

    // Authenticated users without a profile must finish onboarding first.
    if (isAuthenticated && !isProfileComplete) {
      if (isAuthRoute) {
        AppLogger.debug(
          'Authenticated incomplete user on auth route → completeProfile',
          tag: LogTags.router,
        );
        return RoutePaths.completeProfile;
      }

      if (!isPublicRoute && currentPath != RoutePaths.completeProfile) {
        AppLogger.debug(
          'Profile incomplete → completeProfile',
          tag: LogTags.router,
        );
        return RoutePaths.completeProfile;
      }
    }

    // Complete users should never land on the profile completion screen.
    if (isProfileComplete && currentPath == RoutePaths.completeProfile) {
      AppLogger.debug(
        'Profile already complete → home',
        tag: LogTags.router,
      );
      return RoutePaths.home;
    }

    // Unauthenticated users must stay on public routes.
    if (!isAuthenticated &&
        !isPublicRoute &&
        currentPath != RoutePaths.completeProfile) {
      AppLogger.debug(
        'Unauthenticated user on protected route → welcome',
        tag: LogTags.router,
      );
      return RoutePaths.welcome;
    }

    return null;
  }

  /// Checks Remote Config for maintenance mode and forced updates.
  static String? _operationalRedirect(String currentPath) {
    // Avoid redirect loops: operational pages are always allowed.
    if ([
      RoutePaths.forceUpdate,
      RoutePaths.maintenance,
      RoutePaths.splash,
      RoutePaths.loading,
    ].contains(currentPath)) {
      return null;
    }

    try {
      final remoteConfig = GetIt.I<RemoteConfigService>();

      if (remoteConfig.isMaintenanceMode) {
        return RoutePaths.maintenance;
      }

      final forceVersion = remoteConfig.forceUpdateVersion;
      if (forceVersion.isNotEmpty) {
        final packageInfo = GetIt.I<PackageInfo>();
        if (_shouldForceUpdate(packageInfo.version, forceVersion)) {
          return RoutePaths.forceUpdate;
        }
      }
    } catch (e) {
      AppLogger.error('Failed to evaluate operational redirect', error: e);
    }

    return null;
  }

  /// Compares semantic version strings. Returns true when [current] is lower
  /// than or equal to [forced] (i.e. the user must update).
  static bool _shouldForceUpdate(String current, String forced) {
    final currentParts = current.split('.').map(int.tryParse).toList();
    final forcedParts = forced.split('.').map(int.tryParse).toList();
    final length =
        currentParts.length > forcedParts.length
            ? currentParts.length
            : forcedParts.length;

    for (var i = 0; i < length; i++) {
      final c = i < currentParts.length ? currentParts[i] ?? 0 : 0;
      final f = i < forcedParts.length ? forcedParts[i] ?? 0 : 0;
      if (c < f) return true;
      if (c > f) return false;
    }
    return true; // equal version also forces update
  }
}
