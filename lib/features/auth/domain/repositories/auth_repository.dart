import 'package:bloot/features/auth/domain/entities/user.dart';

/// Repository contract for authentication operations.
abstract class AuthRepository {
  /// Signs in with Google and returns the authenticated user.
  Future<User?> signInWithGoogle();

  /// Signs in with Apple and returns the authenticated user.
  Future<User?> signInWithApple();

  /// Returns whether the current user has a complete profile.
  Future<bool> isProfileComplete();

  /// Completes the user profile after first-time social sign-in.
  Future<User> completeProfile({
    required String name,
    required String username,
    String? avatarUrl,
  });

  /// Returns the currently authenticated user, or null if not signed in.
  Future<User?> getCurrentUser();

  /// Signs the user out.
  Future<void> signOut();

  /// Checks if a username is available (not already taken).
  Future<bool> isUsernameAvailable(String username);

  /// Deletes the current user's account and all associated data.
  Future<void> deleteAccount();
}
