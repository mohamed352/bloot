import 'dart:async';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/components/search_bar.dart' as app;
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/chat/domain/entities/chat_user.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/features/chat/domain/repositories/chat_repository.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';

/// Bottom sheet that lets the room host search for users and send them
/// a push-notification invite to join the room.
class InviteFriendSheet extends StatefulWidget {
  const InviteFriendSheet({super.key, required this.roomId});

  final String roomId;

  @override
  State<InviteFriendSheet> createState() => _InviteFriendSheetState();
}

class _InviteFriendSheetState extends State<InviteFriendSheet> {
  final ChatRepository _chatRepository = getIt<ChatRepository>();
  Timer? _debounce;
  List<ChatUser> _users = [];
  bool _loading = false;
  String _query = '';
  String? _sendingToUid;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
      _loading = value.trim().isNotEmpty;
    });
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() => _users = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      try {
        final results = await _chatRepository.searchUsers(trimmed);
        if (mounted) {
          setState(() {
            _users = results;
            _loading = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _users = [];
            _loading = false;
          });
        }
      }
    });
  }

  Future<void> _sendInvite(ChatUser user) async {
    setState(() => _sendingToUid = user.id);
    final cubit = context.read<RoomCubit>();
    final success = await cubit.sendRoomInvite(widget.roomId, user.id);
    if (!mounted) return;
    setState(() => _sendingToUid = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'invite_sent_to'.tr(namedArgs: {'name': user.name})
              : 'failed_to_send_invite'.tr(),
        ),
      ),
    );
    if (success && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  vertical: AppSpacing.sm,
                ),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    Text(
                      'invite_friend'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: colors.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: app.SearchBar(
                  hintText: 'search_players'.tr(),
                  onChanged: _onSearchChanged,
                  autofocus: true,
                ),
              ),
              Expanded(child: _buildBody(context, scrollController)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ScrollController controller) {
    if (_query.trim().isEmpty) {
      return Center(
        child: Text(
          'search_for_players'.tr(),
          style: TextStyle(fontSize: 14, color: context.appColors.textMuted),
        ),
      );
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_users.isEmpty) {
      return Center(
        child: Text(
          'no_players_found'.tr(),
          style: TextStyle(fontSize: 14, color: context.appColors.textMuted),
        ),
      );
    }
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.sm),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        final isSending = _sendingToUid == user.id;
        return ListTile(
          leading: CachedAvatar(imageUrl: user.avatarUrl, size: 44),
          title: Text(
            user.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
          subtitle: user.handle != null
              ? Text(
                  user.handle!,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.appColors.textMuted,
                  ),
                )
              : null,
          trailing: isSending
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.send_rounded,
                    color: ColorManager.primary,
                  ),
                  onPressed: () => _sendInvite(user),
                ),
          onTap: isSending ? null : () => _sendInvite(user),
        );
      },
    );
  }
}
