import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/features/chat/domain/entities/chat.dart';
import 'package:bloot/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:bloot/features/chat/presentation/cubit/chat_state.dart';
import 'package:bloot/features/moderation/domain/repositories/moderation_repository.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late final Stream<Set<String>> _blockedUserIdsStream;
  final TextEditingController _searchController = TextEditingController();
  bool _searchVisible = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _blockedUserIdsStream = getIt<ModerationRepository>().watchBlockedUserIds();
  }

  /// Returns the other participant UID for `dm_<uidA>_<uidB>` conversations.
  String? _otherUserId(String conversationId) {
    final currentUid = getIt<firebase_auth.FirebaseAuth>().currentUser?.uid;
    if (currentUid == null || !conversationId.startsWith('dm_')) return null;
    final parts = conversationId.substring(3).split('_');
    for (final part in parts) {
      if (part.isNotEmpty && part != currentUid) return part;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        state.whenOrNull(
          error: (message) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
        );
      },
      builder: (context, state) {
        final conversations = state is ChatConversationsLoaded
            ? state.conversations
            : <ChatConversation>[];

        return Scaffold(
          backgroundColor: ColorManager.darkCanvas,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Text(
                        'messages'.tr(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.darkTextPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: ColorManager.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _searchVisible
                                ? Icons.close_rounded
                                : Icons.search_rounded,
                            color: ColorManager.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchVisible = !_searchVisible;
                              if (!_searchVisible) {
                                _searchController.clear();
                                _searchQuery = '';
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (_searchVisible)
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(
                        color: ColorManager.darkTextPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'search_messages'.tr(),
                        hintStyle: const TextStyle(
                          color: ColorManager.darkTextMuted,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: ColorManager.darkTextMuted,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: ColorManager.darkSurface,
                        contentPadding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value.toLowerCase());
                      },
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                // Chat list
                Expanded(
                  child: StreamBuilder<Set<String>>(
                    stream: _blockedUserIdsStream,
                    builder: (context, snapshot) {
                      final blockedIds = snapshot.data ?? const <String>{};
                      var visibleConversations = conversations.where((c) {
                        final otherUserId = _otherUserId(c.id);
                        return otherUserId == null ||
                            !blockedIds.contains(otherUserId);
                      }).toList();
                      if (_searchQuery.isNotEmpty) {
                        visibleConversations = visibleConversations
                            .where(
                              (c) =>
                                  c.name.toLowerCase().contains(_searchQuery),
                            )
                            .toList();
                      }

                      return ListView.builder(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        itemCount: visibleConversations.length,
                        itemBuilder: (context, index) {
                          final chat = visibleConversations[index];
                          return _ChatListItem(
                            chat: chat,
                            onTap: () => context.pushNamed(
                              RouteNames.directMessage,
                              pathParameters: {'conversationId': chat.id},
                              extra: chat,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChatListItem extends StatelessWidget {
  const _ChatListItem({required this.chat, required this.onTap});

  final ChatConversation chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = chat.avatarUrl != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: ColorManager.darkSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: ColorManager.darkBorderSoft),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: ColorManager.darkSectionGray,
                    shape: BoxShape.circle,
                    border: Border.all(color: ColorManager.darkBorderSoft),
                  ),
                  child: hasAvatar
                      ? ClipOval(
                          child: Image.network(
                            chat.avatarUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          chat.type == 'rooms'
                              ? Icons.meeting_room_rounded
                              : Icons.emoji_events_rounded,
                          color: ColorManager.primary,
                        ),
                ),
                if (chat.unread > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: ColorManager.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${chat.unread}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: ColorManager.darkTextPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: chat.unread > 0
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: ColorManager.darkTextPrimary,
                          ),
                        ),
                      ),
                      Text(
                        chat.time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorManager.darkTextMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: chat.unread > 0
                          ? ColorManager.darkTextSecondary
                          : ColorManager.darkTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
