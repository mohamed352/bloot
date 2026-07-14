import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/profile/data/models/achievement_model.dart';
import 'package:bloot/features/profile/data/models/game_history_model.dart';
import 'package:bloot/features/profile/data/models/user_profile_model.dart';

@lazySingleton
class ProfileRemoteDataSource {
  ProfileRemoteDataSource({
    required FirebaseFirestore firestore,
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth,
       _storage = storage;

  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseStorage _storage;

  Future<UserProfileModel?> getCurrentUserProfile() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return getUserProfile(user.uid);
  }

  Future<UserProfileModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return _mapDocToModel(uid, data);
    } catch (e) {
      AppLogger.error('Failed to get user profile', error: e, tag: 'Profile');
      return null;
    }
  }

  Future<List<UserProfileModel>> getUserProfiles(List<String> uids) async {
    if (uids.isEmpty) return [];
    try {
      final futures = uids.map(getUserProfile);
      final profiles = await Future.wait(futures);
      return profiles.whereType<UserProfileModel>().toList();
    } catch (e) {
      AppLogger.error('Failed to get user profiles', error: e, tag: 'Profile');
      return [];
    }
  }

  Stream<UserProfileModel?> watchCurrentUserProfile() {
    final user = _firebaseAuth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return _mapDocToModel(snapshot.id, snapshot.data()!);
        })
        .handleError((Object error) {
          AppLogger.error(
            'Failed to watch user profile',
            error: error,
            tag: 'Profile',
          );
          return null;
        });
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await _firestore.collection('users').doc(user.uid).update(data);
  }

  Future<String> uploadAvatar(File file) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final ref = _storage.ref().child('avatars/${user.uid}.jpg');
    final uploadTask = await ref.putFile(file);
    return uploadTask.ref.getDownloadURL();
  }

  Future<List<GameHistoryModel>> getGameHistory(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('gameHistory')
          .orderBy('playedAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map(_mapGameDocToModel).toList();
    } catch (e) {
      AppLogger.error('Failed to get game history', error: e, tag: 'Profile');
      return [];
    }
  }

  Future<List<AchievementModel>> getAchievements(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('achievements')
          .orderBy('unlockedAt', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map(_mapAchievementDocToModel).toList();
    } catch (e) {
      AppLogger.error('Failed to get achievements', error: e, tag: 'Profile');
      return [];
    }
  }

  AchievementModel _mapAchievementDocToModel(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final unlockedAt = data['unlockedAt'];

    return AchievementModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      iconName: data['iconName'] as String?,
      unlockedAt: unlockedAt is Timestamp ? unlockedAt.toDate() : null,
    );
  }

  GameHistoryModel _mapGameDocToModel(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final playedAt = data['playedAt'];

    return GameHistoryModel(
      id: doc.id,
      won: data['won'] == true,
      score: data['score'] as String? ?? '',
      type: data['type'] as String? ?? '',
      durationMinutes: (data['durationMinutes'] as num?)?.toInt(),
      playedAt: playedAt is Timestamp ? playedAt.toDate() : null,
    );
  }

  UserProfileModel _mapDocToModel(String uid, Map<String, dynamic> data) {
    return UserProfileModel(
      uid: uid,
      displayName: data['displayName'] as String?,
      username: data['username'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      bio: data['bio'] as String?,
      region: data['region'] as String?,
      favoriteMode: data['favoriteMode'] as String?,
      level: (data['level'] as num?)?.toInt() ?? 1,
      xp: (data['xp'] as num?)?.toInt() ?? 0,
      xpToNextLevel: (data['xpToNextLevel'] as num?)?.toInt() ?? 100,
      gamesPlayed: (data['gamesPlayed'] as num?)?.toInt() ?? 0,
      gamesWon: (data['gamesWon'] as num?)?.toInt() ?? 0,
      sunGamesPlayed: (data['sunGamesPlayed'] as num?)?.toInt() ?? 0,
      sunGamesWon: (data['sunGamesWon'] as num?)?.toInt() ?? 0,
      hokmGamesPlayed: (data['hokmGamesPlayed'] as num?)?.toInt() ?? 0,
      hokmGamesWon: (data['hokmGamesWon'] as num?)?.toInt() ?? 0,
      followersCount: (data['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (data['followingCount'] as num?)?.toInt() ?? 0,
      isOnline: data['isOnline'] == true,
    );
  }
}
