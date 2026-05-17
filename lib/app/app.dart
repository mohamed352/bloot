import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloot/config/routes/app_router.dart';
import 'package:bloot/core/components/app_text.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/core/localization/language_manager.dart';
import 'package:bloot/core/network/connectivity_cubit.dart';
import 'package:bloot/core/style/theme_manager.dart';
import 'package:bloot/generated/locale_keys.g.dart';

class BlootApp extends StatelessWidget {
  const BlootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConnectivityCubit(),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeManager.themeNotifier,
        builder: (context, themeMode, child) {
          return MaterialApp.router(
            title: LocaleKeys.appName.tr(),
            debugShowCheckedModeBanner: false,

            theme: ThemeManager.lightTheme,
            darkTheme: ThemeManager.darkTheme,
            themeMode: themeMode,

            localizationsDelegates: context.localizationDelegates,
            supportedLocales: LanguageManager.supportedLocales,
            locale: context.locale,

            routerConfig: appRouter,

            builder: (context, child) {
              final colors = context.appColors;
              return BlocBuilder<ConnectivityCubit, ConnectivityState>(
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
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  AppText(
                                    LocaleKeys.commonNoInternet.tr(),
                                    style: const TextStyle(
                                      color: Colors.white,
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
              );
            },
          );
        },
      ),
    );
  }
}
