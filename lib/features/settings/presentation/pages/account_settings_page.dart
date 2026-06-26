import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_cubit.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      appBar: AppBar(
        title: Text('account'.tr()),
        backgroundColor: const Color(0x00000000),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.person_rounded,
              color: ColorManager.primary,
            ),
            title: Text(
              'edit_profile'.tr(),
              style: const TextStyle(color: ColorManager.darkTextPrimary),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: ColorManager.darkTextMuted,
            ),
            onTap: () => context.pushNamed(RouteNames.editProfile),
          ),
          const Divider(color: ColorManager.darkBorderSoft),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.logout_rounded,
              color: ColorManager.error,
            ),
            title: Text(
              'log_out'.tr(),
              style: const TextStyle(color: ColorManager.error),
            ),
            onTap: () {
              context.read<AuthCubit>().signOut();
              context.goNamed(RouteNames.login);
            },
          ),
          const Divider(color: ColorManager.darkBorderSoft),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.delete_forever_rounded,
              color: ColorManager.error,
            ),
            title: Text(
              'delete_account'.tr(),
              style: const TextStyle(color: ColorManager.error),
            ),
            onTap: () => _showDeleteConfirm(context),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.darkSurface,
        title: Text(
          'delete_account'.tr(),
          style: const TextStyle(color: ColorManager.error),
        ),
        content: Text(
          'delete_account_confirm_body'.tr(),
          style: const TextStyle(color: ColorManager.darkTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              context.read<AuthCubit>().deleteAccount();
              context.goNamed(RouteNames.login);
            },
            child: Text(
              'delete_account'.tr(),
              style: const TextStyle(color: ColorManager.error),
            ),
          ),
        ],
      ),
    );
  }
}
