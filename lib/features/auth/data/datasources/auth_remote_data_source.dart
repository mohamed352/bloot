import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/auth/data/models/user_model.dart';
import 'package:bloot/features/auth/domain/exceptions/auth_exception.dart';

@lazySingleton
class AuthRemoteDataSource {
  AuthRemoteDataSource({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       _functions = functions;

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  String? _verificationId;
  int? _resendToken;

  Future<UserModel?> signInWithGoogle() async {
    try {
      AppLogger.info('Starting Google Sign In', tag: 'Auth');

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final GoogleSignInClientAuthorization? authz = await googleUser
          .authorizationClient
          .authorizationForScopes(<String>['email', 'profile']);

      final firebase_auth.OAuthCredential credential =
          firebase_auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: authz?.accessToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
      AppLogger.info('Google Sign In successful', tag: 'Auth');
      return getCurrentUser();
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.error('Google sign in failed', error: e, tag: 'Auth');
      throw AuthException(
        e.message ?? 'Google sign in failed. Please try again.',
        code: e.code,
      );
    } on GoogleSignInException catch (e) {
      AppLogger.error('Google sign in failed', error: e, tag: 'Auth');
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      throw AuthException(
        e.description ?? 'Google sign in failed. Please try again.',
        code: e.code.name,
      );
    } catch (e) {
      AppLogger.error('Google sign in failed', error: e, tag: 'Auth');
      throw const AuthException(
        'Google sign in failed. Please try again.',
        code: 'GOOGLE_SIGN_IN_ERROR',
      );
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    final completer = Completer<void>();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        // Auto-verification (e.g., on Android with Google Play Services)
        AppLogger.info('Phone auto-verification completed', tag: 'Auth');
        try {
          await _firebaseAuth.signInWithCredential(credential);
        } on firebase_auth.FirebaseAuthException catch (e) {
          AppLogger.error('Auto-verification sign-in failed', error: e, tag: 'Auth');
          if (!completer.isCompleted) {
            completer.completeError(
              AuthException(
                e.message ?? 'Auto-verification failed. Please try again.',
                code: e.code,
              ),
            );
          }
          return;
        }
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      verificationFailed: (error) {
        AppLogger.error('Phone verification failed', error: error, tag: 'Auth');
        if (!completer.isCompleted) {
          completer.completeError(
            AuthException(
              error.message ?? 'Phone verification failed. Please try again.',
              code: error.code,
            ),
          );
        }
      },
      codeSent: (verificationId, resendToken) {
        AppLogger.info('OTP code sent', tag: 'Auth');
        _verificationId = verificationId;
        _resendToken = resendToken;
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {
        AppLogger.info('Auto retrieval timeout', tag: 'Auth');
        _verificationId = verificationId;
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      forceResendingToken: _resendToken,
    );

    return completer.future;
  }

  Future<void> verifyOtp(String otp) async {
    final verificationId = _verificationId;
    if (verificationId == null || verificationId.isEmpty) {
      throw const AuthException(
        'Verification ID not found. Please request a new code.',
        code: 'MISSING_VERIFICATION_ID',
      );
    }

    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await _firebaseAuth.signInWithCredential(credential);
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.error('OTP verification failed', error: e, tag: 'Auth');
      throw AuthException(
        e.message ?? 'Invalid OTP. Please try again.',
        code: e.code,
      );
    } catch (e) {
      AppLogger.error('OTP verification error', error: e, tag: 'Auth');
      throw const AuthException(
        'Failed to verify OTP. Please try again.',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  Future<bool> isProfileComplete() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return false;
      final data = doc.data();
      return data?['isProfileComplete'] == true;
    } catch (e) {
      AppLogger.error(
        'Failed to check profile completeness',
        error: e,
        tag: 'Auth',
      );
      return false;
    }
  }

  Future<UserModel> completeProfile({
    required String name,
    required String username,
    String? avatarUrl,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException(
        'User not authenticated.',
        code: 'NOT_AUTHENTICATED',
      );
    }

    final userData = <String, dynamic>{
      'uid': user.uid,
      'phoneNumber': user.phoneNumber ?? '',
      'displayName': name.trim(),
      'username': username.trim().toLowerCase(),
      'avatarUrl': avatarUrl,
      'bio': null,
      'region': null,
      'favoriteMode': null,
      'level': 1,
      'xp': 0,
      'xpToNextLevel': 100,
      'coins': 0,
      'gamesPlayed': 0,
      'gamesWon': 0,
      'sunGamesPlayed': 0,
      'sunGamesWon': 0,
      'hokmGamesPlayed': 0,
      'hokmGamesWon': 0,
      'followersCount': 0,
      'followingCount': 0,
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
      'fcmToken': null,
      'achievements': <String, dynamic>{},
      'settings': <String, dynamic>{
        'voiceChat': true,
        'camera': false,
        'speakerMode': 'speaker',
        'autoRotateGame': true,
        'gameSpeedDefault': 'normal',
        'soundEffects': true,
        'backgroundMusic': false,
        'showOnlineStatus': true,
        'profileVisibility': 'everyone',
        'notifyRoomInvitations': true,
        'notifyTournamentAlerts': true,
        'notifyNewFollowers': true,
        'notifyGameResults': true,
      },
      'isProfileComplete': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));
      AppLogger.info('User profile created/merged in Firestore', tag: 'Auth');
    } catch (e) {
      AppLogger.error('Failed to create user profile', error: e, tag: 'Auth');
      throw const AuthException(
        'Failed to save profile. Please try again.',
        code: 'FIRESTORE_ERROR',
      );
    }

    return UserModel(
      uid: user.uid,
      phoneNumber: user.phoneNumber ?? '',
      displayName: name.trim(),
      username: username.trim().toLowerCase(),
      avatarUrl: avatarUrl,
      isProfileComplete: true,
    );
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        // User authenticated but no Firestore profile yet
        return UserModel(uid: user.uid, phoneNumber: user.phoneNumber ?? '');
      }
      final data = doc.data()!;
      return UserModel(
        uid: user.uid,
        phoneNumber: user.phoneNumber ?? '',
        displayName: data['displayName'] as String?,
        username: data['username'] as String?,
        avatarUrl: data['avatarUrl'] as String?,
        isProfileComplete: data['isProfileComplete'] == true,
      );
    } catch (e) {
      AppLogger.error('Failed to get current user', error: e, tag: 'Auth');
      return UserModel(uid: user.uid, phoneNumber: user.phoneNumber ?? '');
    }
  }

  Future<void> signOut() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        AppLogger.error(
          'Failed to update online status',
          error: e,
          tag: 'Auth',
        );
      }
    }
    await _firebaseAuth.signOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      AppLogger.error('Failed to sign out from Google', error: e, tag: 'Auth');
    }
    _verificationId = null;
    _resendToken = null;
  }

  Future<bool> isUsernameAvailable(String username) async {
    final normalized = username.trim().toLowerCase();
    if (normalized.length < 3) return false;

    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: normalized)
          .limit(1)
          .get();
      return query.docs.isEmpty;
    } catch (e) {
      AppLogger.error(
        'Failed to check username availability',
        error: e,
        tag: 'Auth',
      );
      return false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _functions.httpsCallable('deleteAccount').call<void>();
      try {
        await GoogleSignIn.instance.disconnect();
      } catch (e) {
        AppLogger.error(
          'Failed to disconnect Google account',
          error: e,
          tag: 'Auth',
        );
      }
    } catch (e) {
      AppLogger.error('Failed to delete account', error: e, tag: 'Auth');
      throw const AuthException('Failed to delete account. Please try again.');
    }
  }

  String? get verificationId => _verificationId;
}
