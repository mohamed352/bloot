import 'dart:io';

import 'package:bloot/features/profile/domain/entities/achievement.dart';
import 'package:bloot/features/profile/domain/entities/game_history.dart';
import 'package:bloot/features/profile/domain/entities/user_profile.dart';

/// Repository contract for user profile data access.
///
/// Implementations live in the data layer. Cubits depend on this interface
/// via dependency injection.
abstract class ProfileRepository {
  /// Fetches the current authenticated user's profile from Firestore.
  Future<UserProfile?> getCurrentUserProfile();

  /// Fetches any user's profile by UID.
  Future<UserProfile?> getUserProfile(String uid);

  /// Fetches multiple user profiles by UID.
  Future<List<UserProfile>> getUserProfiles(List<String> uids);

  /// Real-time stream of the current user's profile changes.
  Stream<UserProfile?> watchCurrentUserProfile();

  /// Updates the current user's profile fields in Firestore.
  Future<void> updateProfile(Map<String, dynamic> data);

  /// Uploads an avatar image to Firebase Storage and returns the download URL.
  Future<String> uploadAvatar(File file);

  /// Fetches a user's game history, newest first.
  Future<List<GameHistory>> getGameHistory(String uid);

  /// Fetches a user's achievements.
  Future<List<Achievement>> getAchievements(String uid);
}
