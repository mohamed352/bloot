/// Domain entity representing an authenticated user.
class User {
  const User({
    required this.uid,
    this.displayName,
    this.username,
    this.avatarUrl,
    this.isProfileComplete = false,
  });

  final String uid;
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final bool isProfileComplete;
}
