import 'dart:async';

import 'package:bloot/features/chat/domain/entities/chat.dart';
import 'package:bloot/features/chat/domain/entities/chat_user.dart';

/// Repository contract for chat operations.
abstract class ChatRepository {
  /// Returns the list of all conversations.
  Future<List<ChatConversation>> getConversations();

  /// Returns a real-time stream of messages for the given [conversationId].
  Stream<List<ChatMessage>> watchMessages(String conversationId);

  /// Returns messages for the given [conversationId] (one-shot, mocked fallback).
  Future<List<ChatMessage>> getMessages(String conversationId);

  /// Sends a [message] to [conversationId].
  Future<void> sendMessage(String conversationId, String message);

  /// Searches users by [query] across displayName and username.
  Future<List<ChatUser>> searchUsers(String query);

  /// Creates or retrieves an existing direct conversation with [otherUserId].
  Future<ChatConversation> createDirectConversation(String otherUserId);

  /// Marks [conversationId] as read (clears the unread badge).
  Future<void> markConversationRead(String conversationId);
}
