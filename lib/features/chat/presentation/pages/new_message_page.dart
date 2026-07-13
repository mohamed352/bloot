import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_scaffold.dart';
import 'package:bloot/core/components/custom_app_bar.dart';
import 'package:bloot/core/components/search_bar.dart' as app;
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/features/chat/domain/entities/chat_user.dart';
import 'package:bloot/features/chat/presentation/cubit/new_message_cubit.dart';
import 'package:bloot/features/chat/presentation/cubit/new_message_state.dart';

/// New message compose screen with user search.
class NewMessagePage extends StatefulWidget {
  const NewMessagePage({super.key});

  @override
  State<NewMessagePage> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  String _query = '';
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value);
    _searchDebounce?.cancel();

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      // Clear stale results as soon as the search field is emptied.
      context.read<NewMessageCubit>().reset();
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<NewMessageCubit>().search(trimmed);
      }
    });
  }

  void _onUserTap(BuildContext context, String userId) {
    context.read<NewMessageCubit>().createConversation(userId);
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Text(
        _query.isEmpty ? 'search_for_players'.tr() : 'no_players_found'.tr(),
        style: TextStyle(fontSize: 14, color: context.appColors.textMuted),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: CustomAppBar(title: 'new_message'.tr()),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
            child: app.SearchBar(
              hintText: 'search_players'.tr(),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: BlocConsumer<NewMessageCubit, NewMessageState>(
              listener: (context, state) {
                state.whenOrNull(
                  error: (message) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  },
                  conversationCreated: (conversation) {
                    context.pushNamed(
                      RouteNames.directMessage,
                      pathParameters: {'conversationId': conversation.id},
                      extra: conversation,
                    );
                  },
                );
              },
              builder: (context, state) {
                return state.when(
                  initial: () => _emptyState(context),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  loaded: (users) {
                    if (users.isEmpty) {
                      return _emptyState(context);
                    }
                    return ListView.builder(
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: false,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return _UserListTile(
                          user: user,
                          isCreating: state.maybeWhen(
                            creating: () => true,
                            orElse: () => false,
                          ),
                          onTap: () => _onUserTap(context, user.id),
                        );
                      },
                    );
                  },
                  creating: () =>
                      const Center(child: CircularProgressIndicator()),
                  conversationCreated: (_) => const SizedBox.shrink(),
                  error: (_) => const SizedBox.shrink(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserListTile extends StatelessWidget {
  const _UserListTile({
    required this.user,
    required this.isCreating,
    required this.onTap,
  });

  final ChatUser user;
  final bool isCreating;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fallbackLetter = user.name.isNotEmpty ? user.name[0] : '';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colors.surfaceVariant,
        backgroundImage: user.avatarUrl != null
            ? CachedNetworkImageProvider(user.avatarUrl!)
            : null,
        child: user.avatarUrl == null ? Text(fallbackLetter) : null,
      ),
      title: Text(
        user.name,
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: user.handle != null
          ? Text(
              user.handle!,
              style: TextStyle(color: colors.textMuted, fontSize: 12),
            )
          : null,
      trailing: isCreating
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : TextButton(onPressed: onTap, child: Text('send'.tr())),
    );
  }
}
