import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bloot/config/routes/app_router.dart';
import 'package:bloot/core/components/app_text.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/core/localization/language_manager.dart';
import 'package:bloot/core/network/connectivity_cubit.dart';
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

class BlootApp extends StatelessWidget {
  const BlootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ConnectivityCubit()),
        BlocProvider(create: (_) => getIt<AuthCubit>()),
      ],
      child: MaterialApp.router(
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
