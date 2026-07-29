import 'dart:async';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/cubit/room_state.dart';

class RoomInvitationPage extends StatefulWidget {
  const RoomInvitationPage({super.key, required this.id});
  final String id;

  @override
  State<RoomInvitationPage> createState() => _RoomInvitationPageState();
}

class _RoomInvitationPageState extends State<RoomInvitationPage> {
  Room? _room;
  bool _loading = true;
  bool _joining = false;
  String? _error;
  bool _isAuthenticated = false;
  StreamSubscription<Room>? _roomSubscription;

  @override
  void initState() {
    super.initState();
    _isAuthenticated = getIt<FirebaseAuth>().currentUser != null;
    _loadRoom();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadRoom() async {
    await _roomSubscription?.cancel();
    setState(() {
      _loading = true;
      _error = null;
    });
    // Listen to the room live so a full/started room updates the UI instead
    // of leaving a dead join button.
    _roomSubscription = getIt<RoomRepository>().watchRoom(widget.id).listen(
      (room) {
        if (!mounted) return;
        setState(() {
          _room = room;
          _loading = false;
        });
      },
      onError: (Object e) {
        if (!mounted) return;
        setState(() {
          _error = 'room_not_found'.tr();
          _loading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RoomCubit>(),
      child: BlocListener<RoomCubit, RoomState>(
        listener: (context, state) {
          // Any state other than loading/initial means the join attempt
          // settled — never leave the Join button spinning forever.
          if (_joining && state is! RoomLoading && state is! RoomInitial) {
            setState(() => _joining = false);
          }
          state.whenOrNull(
            created: (room) {
              context.pushNamed(
                RouteNames.roomLobby,
                pathParameters: {'id': room.id},
              );
            },
            error: (message) {
              setState(() => _joining = false);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            },
          );
        },
        child: Builder(
          builder: (context) {
            final room = _room;
            return Scaffold(
              backgroundColor: ColorManager.darkCanvas.withValues(alpha: 0.95),
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ColorManager.darkSurface,
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                        border: Border.all(
                          color: ColorManager.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : _error != null
                          ? _buildErrorState()
                          : room != null
                          ? _buildContent(context, room)
                          : _buildErrorState(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 48,
          color: ColorManager.error,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          _error ?? 'room_not_found'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: ColorManager.darkTextSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(text: 'try_again'.tr(), onPressed: _loadRoom),
      ],
    );
  }

  // [context] must come from below the page's own BlocProvider (the Builder
  // in [build]) — using the State's context here resolves providers above the
  // page, where no RoomCubit exists, so the join call threw and the Join
  // button stayed in its loading state forever (tester ticket, build 11).
  Widget _buildContent(BuildContext context, Room room) {
    final creator = room.players.firstWhere(
      (p) => p.uid == room.creatorUid,
      orElse: () => room.players.first,
    );
    final isFull = room.players.length >= 4;
    final isClosed = room.status != RoomStatus.waiting;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'room_invitation'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ColorManager.darkTextPrimary,
          ),
        ),
        const SizedBox(height: 20),
        CachedAvatar(imageUrl: creator.avatarUrl, size: 64, borderRadius: 32),
        const SizedBox(height: AppSpacing.md),
        Text(
          creator.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorManager.darkTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'invited_you_to_join'.tr(),
          style: const TextStyle(
            fontSize: 13,
            color: ColorManager.darkTextSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: ColorManager.darkSectionGray,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            children: [
              Text(
                room.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.darkTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.meeting_room_rounded,
                    size: 16,
                    color: ColorManager.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    room.type.name.tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: ColorManager.darkTextSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  const Icon(
                    Icons.people_rounded,
                    size: 16,
                    color: ColorManager.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'roomPlayerCount'.tr(
                      namedArgs: {
                        'current': '${room.players.length}',
                        'max': '4',
                      },
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: ColorManager.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        if (isFull)
          Text(
            'room_full'.tr(),
            style: const TextStyle(color: ColorManager.error),
          )
        else if (isClosed)
          Text(
            'room_closed'.tr(),
            style: const TextStyle(color: ColorManager.error),
          )
        else
          GradientButton(
            text: _isAuthenticated ? 'join_room'.tr() : 'login_to_join'.tr(),
            gradient: GradientButton.goldGradient,
            isLoading: _joining,
            onPressed: _joining
                ? null
                : () {
                    if (!_isAuthenticated) {
                      context.goNamed(RouteNames.login);
                      return;
                    }
                    setState(() => _joining = true);
                    final inviteCode = room.inviteCode;
                    if (inviteCode != null && inviteCode.isNotEmpty) {
                      context.read<RoomCubit>().joinRoomByCode(inviteCode);
                    } else {
                      // Rooms created before invite codes existed have no
                      // code — join directly by room id.
                      context.read<RoomCubit>().joinRoomById(room.id);
                    }
                  },
          ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          text: 'decline'.tr(),
          isOutlined: true,
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
