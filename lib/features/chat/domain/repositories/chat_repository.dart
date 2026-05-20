import 'package:bloot/features/chat/domain/entities/chat.dart';

/// Repository contract for chat operations.
abstract class ChatRepository {
  /// Returns the list of all conversations.
  Future<List<ChatConversation>> getConversations();

  /// Returns messages for the given [conversationId].
  Future<List<ChatMessage>> getMessages(String conversationId);

  /// Sends a [message] to [conversationId].
  Future<List<ChatMessage>> sendMessage(String conversationId, String message);
}
