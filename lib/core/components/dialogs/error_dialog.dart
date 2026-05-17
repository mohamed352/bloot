import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/generated/locale_keys.g.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      builder: (_) =>
          ErrorDialog(title: title, message: message, onRetry: onRetry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      backgroundColor: colors.cardBackground,
      icon: Icon(Icons.error_outline_rounded, color: colors.error, size: 48),
      title: Text(title),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry!();
            },
            child: Text(LocaleKeys.commonRetry.tr()),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(LocaleKeys.commonOk.tr()),
        ),
      ],
    );
  }
}
