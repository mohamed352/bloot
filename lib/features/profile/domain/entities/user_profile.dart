/// Domain entity representing a user's profile data.
///
/// This is separate from the Auth [User] entity because profile stats
/// (level, coins, etc.) are not authentication concerns.
class UserProfile {
  const UserProfile({
    required this.uid,
    this.displayName,
    this.username,
    this.avatarUrl,
    this.bio,
    this.region,
    this.favoriteMode,
    this.level = 1,
    this.xp = 0,
    this.xpToNextLevel = 100,
    this.coins = 0,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.sunGamesPlayed = 0,
    this.sunGamesWon = 0,
    this.hokmGamesPlayed = 0,
    this.hokmGamesWon = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isOnline = false,
  });

  final String uid;
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final String? region;
  final String? favoriteMode;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final int coins;
  final int gamesPlayed;
  final int gamesWon;
  final int sunGamesPlayed;
  final int sunGamesWon;
  final int hokmGamesPlayed;
  final int hokmGamesWon;
  final int followersCount;
  final int followingCount;
  final bool isOnline;
}
