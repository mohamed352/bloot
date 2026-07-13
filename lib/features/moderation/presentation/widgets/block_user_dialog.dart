import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/di/injection.dart';
import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/moderation/domain/repositories/moderation_repository.dart';

/// Shows a confirmation dialog and blocks [targetUid] when confirmed.
/// Returns `true` when the user was blocked successfully.
Future<bool> showBlockUserDialog(
  BuildContext context, {
  required String targetUid,
  required String displayName,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: ColorManager.darkSurface,
      title: Text(
        'block_user'.tr(),
        style: const TextStyle(color: ColorManager.darkTextPrimary),
      ),
      content: Text(
        'block_user_confirm'.tr(),
        style: const TextStyle(color: ColorManager.darkTextSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('cancel'.tr()),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: ColorManager.error),
          onPressed: () => Navigator.pop(context, true),
          child: Text('block_user'.tr()),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return false;

  final messenger = ScaffoldMessenger.of(context);
  try {
    await getIt<ModerationRepository>().blockUser(targetUid);
    messenger.showSnackBar(SnackBar(content: Text('user_blocked'.tr())));
    return true;
  } catch (e) {
    AppLogger.error('Failed to block user', error: e, tag: 'Moderation');
    messenger.showSnackBar(SnackBar(content: Text('block_failed'.tr())));
    return false;
  }
}
