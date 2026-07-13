/// Domain entity representing a user blocked by the current user.
class BlockedUser {
  const BlockedUser({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
  });

  final String uid;
  final String displayName;
  final String? avatarUrl;
}
