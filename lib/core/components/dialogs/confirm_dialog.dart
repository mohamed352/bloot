import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bloot/core/components/app_text.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/generated/locale_keys.g.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    this.message,
    required this.onConfirm,
    this.confirmText,
    this.cancelText,
    this.isDestructive = false,
  });

  final String title;
  final String? message;
  final VoidCallback onConfirm;
  final String? confirmText;
  final String? cancelText;
  final bool isDestructive;

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? message,
    required VoidCallback onConfirm,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      backgroundColor: colors.cardBackground,
      title: AppText(
        title,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
        ),
      ),
      content: message != null
          ? AppText(
              message!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            )
          : null,
      actionsPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          ),
          child: AppText(
            cancelText ?? LocaleKeys.commonCancel.tr(),
            style: TextStyle(
              color: colors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: FilledButton.styleFrom(
            backgroundColor:
                isDestructive ? colors.error.withAlpha(25) : colors.primaryLight,
            foregroundColor: isDestructive ? colors.error : colors.primary,
            elevation: 0,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          child: AppText(
            confirmText ?? LocaleKeys.commonConfirm.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
