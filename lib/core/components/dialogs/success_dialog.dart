import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/generated/locale_keys.g.dart';

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({
    super.key,
    required this.title,
    this.message,
    this.onDismiss,
  });

  final String title;
  final String? message;
  final VoidCallback? onDismiss;

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? message,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      builder: (_) =>
          SuccessDialog(title: title, message: message, onDismiss: onDismiss),
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
      icon: Icon(
        Icons.check_circle_outline_rounded,
        color: colors.success,
        size: 48,
      ),
      title: Text(title),
      content: message != null
          ? Text(message!, textAlign: TextAlign.center)
          : null,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onDismiss?.call();
          },
          child: Text(LocaleKeys.commonOk.tr()),
        ),
      ],
    );
  }
}
