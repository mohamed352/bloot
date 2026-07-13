import 'package:bloot/features/moderation/domain/entities/blocked_user.dart';

/// Repository for user reporting and blocking (App Store guideline 1.2).
abstract class ModerationRepository {
  /// Reports a user or content item for moderation review.
  ///
  /// [targetType] is one of: user, room, stream, message.
  Future<void> reportUser({
    required String targetUid,
    required String targetType,
    required String reason,
    String? details,
  });

  /// Blocks [targetUid] for the current user.
  Future<void> blockUser(String targetUid);

  /// Removes [targetUid] from the current user's blocked list.
  Future<void> unblockUser(String targetUid);

  /// Resolves the host UID of a stream (needed to report a streamer).
  Future<String?> getStreamHostUid(String streamId);

  /// Real-time stream of the current user's blocked users.
  Stream<List<BlockedUser>> watchBlockedUsers();

  /// Real-time stream of the blocked user IDs for quick filtering.
  Stream<Set<String>> watchBlockedUserIds();
}
