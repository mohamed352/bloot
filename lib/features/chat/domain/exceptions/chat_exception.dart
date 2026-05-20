/// Base exception for chat-related failures.
class ChatException implements Exception {
  const ChatException(this.message);

  final String message;
}
