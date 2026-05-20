import 'package:bloot/features/auth/domain/entities/user.dart';

/// Repository contract for authentication operations.
abstract class AuthRepository {
  /// Sends an OTP to the given [phoneNumber].
  Future<void> sendOtp(String phoneNumber);

  /// Verifies the [otp] code for the current session.
  Future<void> verifyOtp(String otp);

  /// Returns whether the current user has a complete profile.
  Future<bool> isProfileComplete();

  /// Completes the user profile after first-time OTP verification.
  Future<User> completeProfile({
    required String name,
    required String username,
    String? avatarUrl,
  });

  /// Returns the currently authenticated user, or null if not signed in.
  Future<User?> getCurrentUser();

  /// Signs the user out.
  Future<void> signOut();
}
