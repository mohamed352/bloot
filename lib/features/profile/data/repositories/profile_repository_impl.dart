import 'dart:io';

import 'package:injectable/injectable.dart';

import 'package:bloot/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:bloot/features/profile/data/models/achievement_model.dart';
import 'package:bloot/features/profile/data/models/game_history_model.dart';
import 'package:bloot/features/profile/data/models/user_profile_model.dart';
import 'package:bloot/features/profile/domain/entities/achievement.dart';
import 'package:bloot/features/profile/domain/entities/game_history.dart';
import 'package:bloot/features/profile/domain/entities/user_profile.dart';
import 'package:bloot/features/profile/domain/repositories/profile_repository.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required ProfileRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    final model = await _remoteDataSource.getCurrentUserProfile();
    return model?.toEntity();
  }

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    final model = await _remoteDataSource.getUserProfile(uid);
    return model?.toEntity();
  }

  @override
  Future<List<UserProfile>> getUserProfiles(List<String> uids) async {
    final models = await _remoteDataSource.getUserProfiles(uids);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Stream<UserProfile?> watchCurrentUserProfile() {
    return _remoteDataSource
        .watchCurrentUserProfile()
        .map((model) => model?.toEntity());
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> data) async {
    return _remoteDataSource.updateUserProfile(data);
  }

  @override
  Future<String> uploadAvatar(File file) async {
    return _remoteDataSource.uploadAvatar(file);
  }

  @override
  Future<List<GameHistory>> getGameHistory(String uid) async {
    final models = await _remoteDataSource.getGameHistory(uid);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Achievement>> getAchievements(String uid) async {
    final models = await _remoteDataSource.getAchievements(uid);
    return models.map((m) => m.toEntity()).toList();
  }
}
