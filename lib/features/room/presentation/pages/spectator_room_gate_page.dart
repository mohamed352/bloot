import 'dart:async';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';

/// Spectator holding page for a public room whose game has not started yet.
///
/// Joining from the public tables list is always as a SPECTATOR (joining as
/// a player is done via the room-code search). This page watches the room
/// and automatically opens the live stream as soon as the game starts and
/// the stream doc appears (game start auto-creates it).
class SpectatorRoomGatePage extends StatefulWidget {
  const SpectatorRoomGatePage({super.key, required this.roomId});

  final String roomId;

  @override
  State<SpectatorRoomGatePage> createState() => _SpectatorRoomGatePageState();
}

class _SpectatorRoomGatePageState extends State<SpectatorRoomGatePage> {
  StreamSubscription<Room>? _subscription;
  Room? _room;
  bool _navigated = false;
  bool _roomGone = false;

  @override
  void initState() {
    super.initState();
    _subscription = getIt<RoomRepository>().watchRoom(widget.roomId).listen(
      (room) {
        if (!mounted) return;
        setState(() => _room = room);
        final streamId = room.streamId;
        if (!_navigated &&
            room.isStreaming &&
            streamId != null &&
            streamId.isNotEmpty) {
          _navigated = true;
          context.pushReplacementNamed(
            RouteNames.watchStream,
            pathParameters: {'id': streamId},
          );
        }
      },
      onError: (Object _) {
        if (!mounted) return;
        setState(() => _roomGone = true);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final room = _room;
    final spectatorsAllowed = room?.allowSpectators ?? true;

    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      appBar: AppBar(
        title: Text(room?.name ?? 'public_rooms'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: _roomGone
              ? _Message(
                  icon: Icons.error_outline_rounded,
                  text: 'room_not_found'.tr(),
                )
              : !spectatorsAllowed
              ? _Message(
                  icon: Icons.visibility_off_outlined,
                  text: 'spectators_not_allowed'.tr(),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      decoration: BoxDecoration(
                        color: ColorManager.darkSurface,
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                        border: Border.all(
                          color: ColorManager.darkBorderSoft,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: ColorManager.primary,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'waiting_for_game_to_start'.tr(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: ColorManager.darkTextPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'spectator_auto_open_note'.tr(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: ColorManager.darkTextSecondary,
                            ),
                          ),
                          if (room != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'roomPlayerCount'.tr(
                                namedArgs: {
                                  'current': '${room.players.length}',
                                  'max': '4',
                                },
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                color: ColorManager.darkTextMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 48, color: ColorManager.error),
        const SizedBox(height: AppSpacing.lg),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: ColorManager.darkTextSecondary),
        ),
      ],
    );
  }
}
