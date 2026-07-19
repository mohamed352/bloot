import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:bloot/config/routes/app_router.dart';
import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_text.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/core/localization/language_manager.dart';
import 'package:bloot/core/network/connectivity_cubit.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/core/services/audio_service.dart';
import 'package:bloot/core/services/deep_link_service.dart';
import 'package:bloot/core/services/notification_service.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/style/theme_manager.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bloot/generated/locale_keys.g.dart';

/// Global scroll behavior that adapts physics per platform.
/// iOS/macOS get [BouncingScrollPhysics]; Android and others get [ClampingScrollPhysics].
class _AppScrollBehavior extends ScrollBehavior {
  const _AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return switch (Theme.of(context).platform) {
      TargetPlatform.iOS ||
      TargetPlatform.macOS => const BouncingScrollPhysics(),
      _ => const ClampingScrollPhysics(),
    };
  }
}

class BlootApp extends StatefulWidget {
  const BlootApp({super.key});

  /// Rebuilds the app shell from the root on the next frame.
  ///
  /// Needed after a runtime locale switch: strings resolved through the
  /// context-less `.tr()` extension hold no dependency on [Localizations],
  /// so already-built screens keep the previous language until they happen
  /// to rebuild for another reason. Bumping the app key forces every screen
  /// to rebuild against the freshly loaded translations.
  static void restartApp() => _restartAppCallback?.call();
  static VoidCallback? _restartAppCallback;

  @override
  State<BlootApp> createState() => _BlootAppState();
}

class _BlootAppState extends State<BlootApp> {
  StreamSubscription<dynamic>? _deepLinkSub;
  StreamSubscription<dynamic>? _fcmSub;
  DeepLinkService? _deepLinkService;
  NotificationService? _notificationService;
  Key _appKey = const ValueKey('bloot-app');

  @override
  void initState() {
    super.initState();
    BlootApp._restartAppCallback = () {
      if (mounted) setState(() => _appKey = UniqueKey());
    };
    _initDeepLinks();
    _initFcmNavigation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _notificationService?.syncLocale(context.locale.languageCode);
      }
    });
  }

  void _initDeepLinks() {
    _deepLinkService = getIt<DeepLinkService>();
    _deepLinkService!.initialize().then((_) {
      _deepLinkSub = _deepLinkService!.onLink.listen(_handleDeepLink);
    });
  }

  void _initFcmNavigation() {
    _notificationService = getIt<NotificationService>();
    _fcmSub = _notificationService!.onMessageOpenedApp.listen(
      _handleFcmMessage,
    );
  }

  void _handleDeepLink(Uri uri) {
    final isInviteScheme = uri.host == 'room-invite';
    final isInviteHttps =
        uri.host == 'bloot.app' &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments.first == 'room-invite';

    if (isInviteScheme || isInviteHttps) {
      final roomId = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      if (roomId.isNotEmpty) {
        appRouter.goNamed(
          RouteNames.roomInvitation,
          pathParameters: {'id': roomId},
        );
      }
    }
  }

  void _handleFcmMessage(dynamic message) {
    final data = message.data as Map<String, dynamic>?;
    if (data == null) return;

    final type = data['type'] as String?;
    final roomId = data['roomId'] as String?;
    final gameId = data['gameId'] as String?;
    final conversationId = data['conversationId'] as String?;

    switch (type) {
      case 'roomInvite':
        if (roomId != null && roomId.isNotEmpty) {
          appRouter.goNamed(
            RouteNames.roomInvitation,
            pathParameters: {'id': roomId},
          );
        }
      case 'chatMessage':
        if (conversationId != null && conversationId.isNotEmpty) {
          appRouter.goNamed(
            RouteNames.directMessage,
            pathParameters: {'conversationId': conversationId},
          );
        }
      case 'gameStarting':
        if (gameId != null && gameId.isNotEmpty) {
          appRouter.goNamed(
            RouteNames.gamePlay,
            pathParameters: {'id': gameId},
          );
        }
    }
  }

  @override
  void dispose() {
    BlootApp._restartAppCallback = null;
    _deepLinkSub?.cancel();
    _fcmSub?.cancel();
    _deepLinkService?.dispose();
    _notificationService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AgoraService>(create: (_) => getIt<AgoraService>()),
        Provider<AudioService>(create: (_) => getIt<AudioService>()),
        BlocProvider(create: (_) => ConnectivityCubit()),
        BlocProvider(create: (_) => getIt<AuthCubit>()),
      ],
      child: MaterialApp.router(
        key: _appKey,
        title: LocaleKeys.appName.tr(),
        debugShowCheckedModeBanner: false,
        theme: ThemeManager.darkTheme,
        themeMode: ThemeMode.dark,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: LanguageManager.supportedLocales,
        locale: context.locale,
        routerConfig: appRouter,
        scrollBehavior: const _AppScrollBehavior(),
        builder: (context, child) {
          final colors = context.appColors;
          return MediaQuery.withClampedTextScaling(
            minScaleFactor: 0.8,
            maxScaleFactor: 1.3,
            child: BlocBuilder<ConnectivityCubit, ConnectivityState>(
              builder: (context, state) {
                return Stack(
                  children: [
                    child ?? const SizedBox.shrink(),
                    if (!state.isConnected)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          bottom: false,
                          child: Container(
                            width: double.infinity,
                            color: colors.error,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.wifi_off_rounded,
                                  color: ColorManager.darkTextPrimary,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                AppText(
                                  LocaleKeys.commonNoInternet.tr(),
                                  style: const TextStyle(
                                    color: ColorManager.darkTextPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
