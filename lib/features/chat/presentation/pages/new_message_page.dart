import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_scaffold.dart';
import 'package:bloot/core/components/custom_app_bar.dart';
import 'package:bloot/core/components/search_bar.dart' as app;
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/features/chat/domain/entities/chat.dart';

/// New message compose screen with user search.
class NewMessagePage extends StatefulWidget {
  const NewMessagePage({super.key});

  @override
  State<NewMessagePage> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  String _query = '';

  // TODO: Replace with real user search from a Cubit
  final List<ChatConversation> _users = [];

  List<ChatConversation> get _filteredUsers {
    if (_query.isEmpty) return _users;
    return _users.where((u) {
      return u.name.toLowerCase().contains(_query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final filtered = _filteredUsers;

    return AppScaffold(
      appBar: const CustomAppBar(
        title: 'New Message',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
            child: app.SearchBar(
              hintText: 'Search players...',
              onChanged: (String value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      _query.isEmpty
                          ? 'Search for players to message'
                          : 'No players found',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textMuted,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final user = filtered[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colors.surfaceVariant,
                          child: Text(user.name[0]),
                        ),
                        title: Text(
                          user.name,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: TextButton(
                          onPressed: () => context.pushNamed(
                            RouteNames.directMessage,
                            pathParameters: {'userId': user.id},
                          ),
                          child: const Text('Send'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
