import 'package:flutter/material.dart';
import 'package:bloot/core/extension/context_values.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key, this.message});

  final String? message;

  static Future<void> show(BuildContext context, {String? message}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingDialog(message: message),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsetsDirectional.all(32),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: colors.primary, strokeWidth: 3),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: TextStyle(fontSize: 14, color: colors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
