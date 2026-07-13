import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/moderation/presentation/cubit/blocked_users_cubit.dart';

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      appBar: AppBar(
        title: Text('blocked_users'.tr()),
        backgroundColor: const Color(0x00000000),
        elevation: 0,
      ),
      body: BlocBuilder<BlockedUsersCubit, BlockedUsersState>(
        builder: (context, state) {
          return switch (state) {
            BlockedUsersInitial() => const Center(
              child: CircularProgressIndicator(),
            ),
            BlockedUsersError(:final message) => Center(
              child: Text(
                message,
                style: const TextStyle(color: ColorManager.darkTextSecondary),
              ),
            ),
            BlockedUsersLoaded(:final users) =>
              users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.block_rounded,
                            size: 48,
                            color: ColorManager.darkTextMuted,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'no_blocked_users'.tr(),
                            style: const TextStyle(
                              color: ColorManager.darkTextMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: users.length,
                      separatorBuilder: (_, _) =>
                          const Divider(color: ColorManager.darkBorderSoft),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CachedAvatar(
                            imageUrl: user.avatarUrl,
                            size: 44,
                            borderRadius: AppRadius.full,
                          ),
                          title: Text(
                            user.displayName.isNotEmpty
                                ? user.displayName
                                : 'User',
                            style: const TextStyle(
                              color: ColorManager.darkTextPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: TextButton(
                            onPressed: () => _unblock(context, user.uid),
                            child: Text('unblock'.tr()),
                          ),
                        );
                      },
                    ),
          };
        },
      ),
    );
  }

  Future<void> _unblock(BuildContext context, String uid) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<BlockedUsersCubit>().unblock(uid);
      messenger.showSnackBar(SnackBar(content: Text('user_unblocked'.tr())));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text('block_failed'.tr())));
    }
  }
}
