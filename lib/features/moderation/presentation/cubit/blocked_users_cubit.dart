import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/moderation/domain/entities/blocked_user.dart';
import 'package:bloot/features/moderation/domain/repositories/moderation_repository.dart';

sealed class BlockedUsersState {
  const BlockedUsersState();
}

final class BlockedUsersInitial extends BlockedUsersState {
  const BlockedUsersInitial();
}

final class BlockedUsersLoaded extends BlockedUsersState {
  const BlockedUsersLoaded({required this.users});

  final List<BlockedUser> users;
}

final class BlockedUsersError extends BlockedUsersState {
  const BlockedUsersError({required this.message});

  final String message;
}

@injectable
class BlockedUsersCubit extends Cubit<BlockedUsersState> {
  BlockedUsersCubit({required ModerationRepository moderationRepository})
    : _moderationRepository = moderationRepository,
      super(const BlockedUsersInitial());

  final ModerationRepository _moderationRepository;
  StreamSubscription<List<BlockedUser>>? _subscription;

  void watchBlockedUsers() {
    _subscription?.cancel();
    _subscription = _moderationRepository.watchBlockedUsers().listen(
      (users) {
        if (isClosed) return;
        emit(BlockedUsersLoaded(users: users));
      },
      onError: (Object e) {
        AppLogger.error('Failed to watch blocked users', error: e);
        if (!isClosed) {
          emit(
            const BlockedUsersError(message: 'Failed to load blocked users.'),
          );
        }
      },
    );
  }

  Future<void> unblock(String uid) {
    return _moderationRepository.unblockUser(uid);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
