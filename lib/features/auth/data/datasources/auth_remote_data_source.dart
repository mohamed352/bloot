import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:injectable/injectable.dart';

import 'package:bloot/features/auth/data/models/user_model.dart';

@lazySingleton
class AuthRemoteDataSource {
  AuthRemoteDataSource({required firebase_auth.FirebaseAuth firebaseAuth})
    : _firebaseAuth = firebaseAuth;

  final firebase_auth.FirebaseAuth _firebaseAuth;

  Future<void> sendOtp(String phoneNumber) async {
    // TODO: Implement Firebase Phone Auth verification
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  Future<void> verifyOtp(String otp) async {
    // TODO: Implement OTP credential sign-in
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  Future<bool> isProfileComplete() async {
    // TODO: Check Firestore user document for profile completeness
    return false;
  }

  Future<UserModel> completeProfile({
    required String name,
    required String username,
    String? avatarUrl,
  }) async {
    // TODO: Write profile to Firestore and return updated user
    final user = _firebaseAuth.currentUser;
    return UserModel(
      uid: user?.uid ?? 'mock_uid',
      phoneNumber: user?.phoneNumber ?? '+966500000000',
      displayName: name,
      username: username,
      avatarUrl: avatarUrl,
      isProfileComplete: true,
    );
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel(uid: user.uid, phoneNumber: user.phoneNumber ?? '');
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
