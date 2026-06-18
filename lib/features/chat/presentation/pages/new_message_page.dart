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

  @override
  void initState() {
    super.initState();
    // Load all users on first open (MVP: small user base)
    context.read<NewMessageCubit>().search('');
  }

  void _onUserTap(BuildContext context, String userId) {
    context.read<NewMessageCubit>().createConversation(userId);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppScaffold(
      appBar: CustomAppBar(title: 'new_message'.tr()),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
            child: app.SearchBar(
              hintText: 'search_players'.tr(),
              onChanged: (String value) {
                setState(() => _query = value);
                context.read<NewMessageCubit>().search(value);
              },
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
                  initial: () => const SizedBox.shrink(),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  loaded: (users) {
                    if (users.isEmpty) {
                      return Center(
                        child: Text(
                          _query.isEmpty
                              ? 'search_for_players'.tr()
                              : 'no_players_found'.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textMuted,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colors.surfaceVariant,
                            backgroundImage: user.avatarUrl != null
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            child: user.avatarUrl == null
                                ? Text(user.name.isNotEmpty ? user.name[0] : '')
                                : null,
                          ),
                          title: Text(
                            user.name,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: state.maybeWhen(
                            creating: () => const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            orElse: () => TextButton(
                              onPressed: () => _onUserTap(context, user.id),
                              child: Text('send'.tr()),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  creating: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
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
