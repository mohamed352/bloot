import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/generated/locale_keys.g.dart';

class GlobalErrorScreen extends StatelessWidget {
  const GlobalErrorScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.onRetry,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: colors.error,
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: onRetry,
                    child: Text(LocaleKeys.commonRetry.tr()),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
