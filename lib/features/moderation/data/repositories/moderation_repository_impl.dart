import 'package:injectable/injectable.dart';

import 'package:bloot/features/moderation/data/datasources/moderation_remote_data_source.dart';
import 'package:bloot/features/moderation/domain/entities/blocked_user.dart';
import 'package:bloot/features/moderation/domain/repositories/moderation_repository.dart';

@LazySingleton(as: ModerationRepository)
class ModerationRepositoryImpl implements ModerationRepository {
  ModerationRepositoryImpl({
    required ModerationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ModerationRemoteDataSource _remoteDataSource;

  @override
  Future<void> reportUser({
    required String targetUid,
    required String targetType,
    required String reason,
    String? details,
  }) {
    return _remoteDataSource.reportUser(
      targetUid: targetUid,
      targetType: targetType,
      reason: reason,
      details: details,
    );
  }

  @override
  Future<void> blockUser(String targetUid) {
    return _remoteDataSource.blockUser(targetUid);
  }

  @override
  Future<void> unblockUser(String targetUid) {
    return _remoteDataSource.unblockUser(targetUid);
  }

  @override
  Future<String?> getStreamHostUid(String streamId) {
    return _remoteDataSource.getStreamHostUid(streamId);
  }

  @override
  Stream<List<BlockedUser>> watchBlockedUsers() {
    return _remoteDataSource.watchBlockedUsers();
  }

  @override
  Stream<Set<String>> watchBlockedUserIds() {
    return watchBlockedUsers().map(
      (users) => users.map((user) => user.uid).toSet(),
    );
  }
}
