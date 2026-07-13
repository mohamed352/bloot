/// Domain entity representing a user that can be messaged.
class ChatUser {
  const ChatUser({
    required this.id,
    required this.displayName,
    this.username,
    this.avatarUrl,
  });

  final String id;
  final String displayName;
  final String? username;
  final String? avatarUrl;

  /// Best name to show in the UI.
  String get name => displayName.isNotEmpty ? displayName : username ?? '';

  /// Optional secondary handle to show under the name.
  String? get handle => username?.isNotEmpty == true ? '@$username' : null;
}
