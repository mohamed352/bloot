import 'package:flutter/material.dart';
import 'package:bloot/core/components/app_text.dart';
import 'package:bloot/core/extension/context_values.dart';

enum AppSnackBarType { success, error, warning, info }

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final colors = context.appColors;

    Color backgroundColor;
    Color textColor = Colors.white;
    IconData icon;

    switch (type) {
      case AppSnackBarType.success:
        backgroundColor = colors.success;
        icon = Icons.check_circle_rounded;
        break;
      case AppSnackBarType.error:
        backgroundColor = colors.error;
        icon = Icons.error_rounded;
        break;
      case AppSnackBarType.warning:
        backgroundColor = colors.warning;
        icon = Icons.warning_rounded;
        textColor = Colors.black87;
        break;
      case AppSnackBarType.info:
        backgroundColor = colors.textPrimary;
        icon = Icons.info_rounded;
        textColor = colors.background;
        break;
    }

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      margin: const EdgeInsetsDirectional.only(bottom: 24, start: 16, end: 16),
      duration: duration,
      content: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: AppText(
                message,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
