import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/components/empty_state_widget.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/cubit/room_state.dart';
import 'package:bloot/features/room/domain/entities/room.dart';

class PublicRoomsPage extends StatefulWidget {
  const PublicRoomsPage({super.key});

  @override
  State<PublicRoomsPage> createState() => _PublicRoomsPageState();
}

class _PublicRoomsPageState extends State<PublicRoomsPage> {
  bool _joining = false;

  @override
  void initState() {
    super.initState();
    context.read<RoomCubit>().watchPublicRooms();
  }

  void _joinRoom(BuildContext context, Room room) {
    if (_joining || room.inviteCode == null || room.inviteCode!.isEmpty) return;
    setState(() => _joining = true);
    context.read<RoomCubit>().joinRoomByCode(room.inviteCode!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      appBar: AppBar(
        title: Text('public_rooms'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<RoomCubit, RoomState>(
        listener: (context, state) {
          state.whenOrNull(
            created: (room) {
              setState(() => _joining = false);
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
        builder: (context, state) {
          final rooms = state is RoomPublicListLoaded ? state.rooms : <Room>[];
          final loading = state is RoomLoading;

          if (loading && rooms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (rooms.isEmpty) {
            return EmptyStateWidget(
              title: 'no_public_rooms'.tr(),
              icon: Icons.meeting_room_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<RoomCubit>().watchPublicRooms();
            },
            child: ListView.builder(
              padding: const EdgeInsetsDirectional.all(
                AppSpacing.screenHorizontal,
              ),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return _RoomCard(
                  room: room,
                  joining: _joining,
                  onTap: () => _joinRoom(context, room),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.room,
    required this.onTap,
    this.joining = false,
  });

  final Room room;
  final VoidCallback onTap;
  final bool joining;

  @override
  Widget build(BuildContext context) {
    final host = room.players.firstWhere(
      (p) => p.uid == room.creatorUid,
      orElse: () => room.players.first,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: ColorManager.darkSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: ColorManager.darkBorderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CachedAvatar(
                  imageUrl: host.avatarUrl,
                  size: 40,
                  borderRadius: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: ColorManager.darkTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        host.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorManager.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ColorManager.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '${room.players.length}/4',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (room.voiceEnabled)
                  _Badge(icon: Icons.mic_rounded, label: 'voice_chat'.tr()),
                if (room.cameraEnabled) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _Badge(icon: Icons.videocam_rounded, label: 'camera'.tr()),
                ],
                const Spacer(),
                SizedBox(
                  height: 32,
                  child: AppButton(
                    text: 'join_table'.tr(),
                    width: 100,
                    onPressed: joining ? null : onTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: ColorManager.darkSectionGray,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: ColorManager.darkTextMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: ColorManager.darkTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
