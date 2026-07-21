import 'dart:async';

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
import 'package:bloot/features/chat/domain/entities/chat_user.dart';
import 'package:bloot/features/chat/domain/repositories/chat_repository.dart';
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
  Timer? _searchDebounce;
  List<ChatUser> _accountResults = [];
  bool _searchingAccounts = false;

  @override
  void initState() {
    super.initState();
    _blockedUserIdsStream = getIt<ModerationRepository>().watchBlockedUserIds();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value.toLowerCase());
    _searchDebounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _accountResults = [];
        _searchingAccounts = false;
      });
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _searchAccounts(trimmed);
    });
  }

  /// Searches Firestore for user accounts so the search field works even
  /// when there is no existing conversation with the queried name.
  Future<void> _searchAccounts(String query) async {
    setState(() => _searchingAccounts = true);
    try {
      final users = await getIt<ChatRepository>().searchUsers(query);
      if (!mounted) return;
      setState(() {
        _accountResults = users;
        _searchingAccounts = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _accountResults = [];
        _searchingAccounts = false;
      });
    }
  }

  Future<void> _openConversationWith(String userId) async {
    try {
      final conversation = await getIt<ChatRepository>()
          .createDirectConversation(userId);
      if (!mounted) return;
      context.pushNamed(
        RouteNames.directMessage,
        pathParameters: {'conversationId': conversation.id},
        extra: conversation,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed_to_start_conversation'.tr())),
      );
    }
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
                      onChanged: _onSearchChanged,
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

                      // Account results that don't already have a visible
                      // conversation match (avoid duplicate rows).
                      final accountResults = _searchQuery.isEmpty
                          ? <ChatUser>[]
                          : _accountResults
                                .where(
                                  (u) => !visibleConversations.any(
                                    (c) => _otherUserId(c.id) == u.id,
                                  ),
                                )
                                .toList();

                      final showSpinner =
                          _searchQuery.isNotEmpty && _searchingAccounts;
                      final showEmptyState =
                          _searchQuery.isNotEmpty &&
                          !_searchingAccounts &&
                          visibleConversations.isEmpty &&
                          accountResults.isEmpty;

                      if (showSpinner) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (showEmptyState) {
                        return Center(
                          child: Text(
                            'no_players_found'.tr(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: ColorManager.darkTextMuted,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        itemCount:
                            visibleConversations.length +
                            accountResults.length,
                        itemBuilder: (context, index) {
                          if (index < visibleConversations.length) {
                            final chat = visibleConversations[index];
                            return _ChatListItem(
                              chat: chat,
                              onTap: () => context.pushNamed(
                                RouteNames.directMessage,
                                pathParameters: {'conversationId': chat.id},
                                extra: chat,
                              ),
                            );
                          }
                          final user =
                              accountResults[index -
                                  visibleConversations.length];
                          return _AccountListItem(
                            user: user,
                            onTap: () => _openConversationWith(user.id),
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

/// A user account search result row; tapping opens (or creates) the DM.
class _AccountListItem extends StatelessWidget {
  const _AccountListItem({required this.user, required this.onTap});

  final ChatUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;
    final fallbackLetter = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

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
                        user.avatarUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(
                        fallbackLetter,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.primary,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: ColorManager.darkTextPrimary,
                    ),
                  ),
                  if (user.handle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.handle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: ColorManager.darkTextMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 18,
              color: ColorManager.primary,
            ),
          ],
        ),
      ),
    );
  }
}
