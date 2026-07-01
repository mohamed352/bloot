import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/auth/data/models/user_model.dart';
import 'package:bloot/features/auth/domain/exceptions/auth_exception.dart';

@lazySingleton
class AuthRemoteDataSource {
  AuthRemoteDataSource({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _functions = functions;

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

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
      // Force a server read so we never decide profile completeness from stale
      // local cache after a logout/re-login cycle.
      return getCurrentUser(forceServer: true);
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

  Future<UserModel?> signInWithApple() async {
    try {
      AppLogger.info('Starting Apple Sign In', tag: 'Auth');

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = firebase_auth.OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      await _firebaseAuth.signInWithCredential(oauthCredential);
      AppLogger.info('Apple Sign In successful', tag: 'Auth');
      // Force a server read so we never decide profile completeness from stale
      // local cache after a logout/re-login cycle.
      return getCurrentUser(forceServer: true);
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.error('Apple sign in failed', error: e, tag: 'Auth');
      throw AuthException(
        e.message ?? 'Apple sign in failed. Please try again.',
        code: e.code,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      AppLogger.error('Apple sign in failed', error: e, tag: 'Auth');
      if (e.code == AuthorizationErrorCode.canceled) {
        return null;
      }
      throw AuthException(
        e.message,
        code: e.code.name,
      );
    } catch (e) {
      AppLogger.error('Apple sign in failed', error: e, tag: 'Auth');
      throw const AuthException(
        'Apple sign in failed. Please try again.',
        code: 'APPLE_SIGN_IN_ERROR',
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
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Failed to check profile completeness',
        error: e,
        tag: 'Auth',
      );
      throw AuthException(
        e.message ?? 'Failed to check profile. Please try again.',
        code: e.code,
      );
    } catch (e) {
      AppLogger.error(
        'Failed to check profile completeness',
        error: e,
        tag: 'Auth',
      );
      throw const AuthException(
        'Failed to check profile. Please try again.',
        code: 'PROFILE_CHECK_ERROR',
      );
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
      displayName: name.trim(),
      username: username.trim().toLowerCase(),
      avatarUrl: avatarUrl,
      isProfileComplete: true,
    );
  }

  Future<UserModel?> getCurrentUser({bool forceServer = false}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    try {
      final options =
          forceServer ? const GetOptions(source: Source.server) : null;
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get(options);
      if (!doc.exists) {
        // User authenticated but no Firestore profile yet
        AppLogger.info(
          'No Firestore profile found for uid=${user.uid}',
          tag: 'Auth',
        );
        return UserModel(uid: user.uid);
      }
      final data = doc.data()!;
      final isComplete = data['isProfileComplete'] == true;
      AppLogger.info(
        'Firestore profile loaded for uid=${user.uid}, '
        'isProfileComplete=$isComplete',
        tag: 'Auth',
      );
      return UserModel(
        uid: user.uid,
        displayName: data['displayName'] as String?,
        username: data['username'] as String?,
        avatarUrl: data['avatarUrl'] as String?,
        isProfileComplete: isComplete,
      );
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Failed to get current user from Firestore',
        error: e,
        tag: 'Auth',
      );
      throw AuthException(
        'Failed to load profile. Please check your connection and try again.',
        code: e.code,
      );
    } catch (e) {
      AppLogger.error('Failed to get current user', error: e, tag: 'Auth');
      throw const AuthException(
        'Failed to load profile. Please try again.',
        code: 'PROFILE_LOAD_ERROR',
      );
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
}
