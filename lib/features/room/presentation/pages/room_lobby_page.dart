import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/generated/locale_keys.g.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/cubit/room_state.dart';
import 'package:bloot/features/room/presentation/widgets/room_settings_bottom_sheet.dart';
import 'package:bloot/features/room/presentation/widgets/invite_friend_sheet.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/features/room/presentation/widgets/seat_widget.dart';

class RoomLobbyPage extends StatefulWidget {
  const RoomLobbyPage({super.key, required this.id});
  final String id;

  @override
  State<RoomLobbyPage> createState() => _RoomLobbyPageState();
}

class _RoomLobbyPageState extends State<RoomLobbyPage>
    with WidgetsBindingObserver {
  AgoraService? _agoraService;
  bool _bypassLeaveHandling = false;

  /// Uid of the seat the creator has selected for a team swap/move. Null when
  /// no team-management selection is active.
  String? _selectedSeatUid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _agoraService ??= context.read<AgoraService>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final agoraService = _agoraService;
    if (agoraService == null) return;
    if (state == AppLifecycleState.paused) {
      agoraService.enterBackgroundMode();
    } else if (state == AppLifecycleState.resumed) {
      agoraService.leaveBackgroundMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _bypassLeaveHandling,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _bypassLeaveHandling) return;
        final cubit = context.read<RoomCubit>();
        // The cubit may already be closed if the user double-pressed back.
        if (cubit.isClosed) return;
        final router = GoRouter.of(context);
        final left = await cubit.leaveRoom(widget.id);
        // Only navigate away when the leave succeeded; on failure an error
        // snackbar is shown and the user stays to retry.
        if (mounted && left) router.goNamed(RouteNames.home);
      },
      child: BlocConsumer<RoomCubit, RoomState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (message) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            },
            gameStarted: (gameId) {
              context.pushNamed(
                RouteNames.gamePlay,
                pathParameters: {'id': gameId},
              );
            },
            kicked: () {
              // The cubit already cleaned up the room. Bypass the lobby's
              // back/leave handler so navigation Home is not intercepted as a
              // voluntary leave (which would emit another loaded state).
              _bypassLeaveHandling = true;
              context.goNamed(RouteNames.home);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('kicked_from_room'.tr())));
            },
          );
        },
        builder: (context, state) {
          final room = state is RoomLoaded ? state.room : null;
          final players = room?.players ?? [];
          final readyCount = players.where((p) => p.isReady).length;
          final allReady = readyCount == 4 && players.length == 4;
          final isReady =
              room?.players.any((p) => p.isMe && p.isReady) ?? false;
          final isParticipant = players.any((p) => p.isMe);
          final isCreator =
              room?.creatorUid != null &&
              room?.players.any((p) => p.isMe && p.uid == room.creatorUid) ==
                  true;

          // Derive seats from teams, not from join order: the local player
          // sits at the bottom, their teammate at the top, and the opposing
          // team on the left/right. Falls back safely for incomplete rooms
          // (empty seats simply show the invite placeholder).
          RoomPlayer? localPlayer;
          for (final p in players) {
            if (p.isMe) {
              localPlayer = p;
              break;
            }
          }
          localPlayer ??= players.isNotEmpty ? players.first : null;
          final localUid = localPlayer?.uid;
          final localTeam = localPlayer?.team;
          RoomPlayer? partner;
          final opponents = <RoomPlayer>[];
          for (final p in players) {
            if (p.uid == localUid) continue;
            if (p.team == localTeam) {
              partner ??= p;
            } else {
              opponents.add(p);
            }
          }
          final opponentLeft = opponents.isNotEmpty ? opponents[0] : null;
          final opponentRight = opponents.length > 1 ? opponents[1] : null;

          return Scaffold(
            backgroundColor: ColorManager.darkCanvas,
            appBar: AppBar(
              title: Text('room_lobby'.tr()),
              backgroundColor: const Color(0x00000000),
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  onPressed: room?.inviteCode != null
                      ? () {
                          Share.share(
                            LocaleKeys.shareRoomMessage.tr(
                              namedArgs: {
                                'code': room!.inviteCode!,
                                'link':
                                    'https://bloot.app/room-invite/${room.id}',
                              },
                            ),
                          );
                        }
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.settings_rounded),
                  onPressed: room == null
                      ? null
                      : () {
                          // Capture the cubit BEFORE opening the sheet: the
                          // modal bottom sheet is a new route whose context
                          // cannot see this route's BlocProvider, so calling
                          // context.read<RoomCubit>() from inside the sheet
                          // throws ProviderNotFoundException and the leave
                          // silently does nothing.
                          final roomCubit = context.read<RoomCubit>();
                          final router = GoRouter.of(context);
                          showModalBottomSheet<void>(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) => RoomSettingsBottomSheet(
                              room: room,
                              onLeave: () async {
                                final left = await roomCubit.leaveRoom(
                                  room.id,
                                );
                                if (left) {
                                  router.goNamed(RouteNames.home);
                                }
                              },
                            ),
                          );
                        },
                ),
              ],
            ),
            body: Stack(
              children: [
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: Column(
                      children: [
                        // Room code with Share button
                        Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: ColorManager.darkSurface,
                            borderRadius: BorderRadius.circular(
                              AppRadius.cardCompact,
                            ),
                            border: Border.all(
                              color: ColorManager.darkBorderSoft,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.meeting_room_rounded,
                                color: ColorManager.primary,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'room_code'.tr(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: ColorManager.darkTextSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    room?.inviteCode ?? '---',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: ColorManager.darkTextPrimary,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              _IconButton(
                                icon: Icons.copy_rounded,
                                onTap: room?.inviteCode != null
                                    ? () {
                                        Clipboard.setData(
                                          ClipboardData(
                                            text: room!.inviteCode!,
                                          ),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              LocaleKeys.room_code_copied.tr(),
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _IconButton(
                                icon: Icons.share_rounded,
                                onTap: room?.inviteCode != null
                                    ? () {
                                        Share.share(
                                          LocaleKeys.shareRoomMessage.tr(
                                            namedArgs: {
                                              'code': room!.inviteCode!,
                                              'link':
                                                  'https://bloot.app/room-invite/${room.id}',
                                            },
                                          ),
                                        );
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Waiting for players status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.hourglass_empty_rounded,
                              size: 16,
                              color: ColorManager.darkTextMuted,
                            ),
                            const SizedBox(width: AppSpacing.smCompact),
                            Text(
                              '${players.length}/4 ${'players'.tr()} • $readyCount ${'ready'.tr()}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: ColorManager.darkTextMuted,
                              ),
                            ),
                          ],
                        ),
                        // Hint shown while the creator is picking a swap/move
                        // target for the selected seat.
                        if (isCreator && _selectedSeatUid != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            LocaleKeys.tap_seat_to_move_hint.tr(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ColorManager.info,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xxl),
                        // Diamond seat layout
                        // Partner (other player on the local team) at top
                        SeatWidget(
                          player: partner,
                          label: LocaleKeys.your_partner.tr(),
                          position: SeatPosition.top,
                          isCreator: isCreator,
                          inviteCode: room?.inviteCode,
                          onKick: (uid) => context.read<RoomCubit>().kickPlayer(
                            room!.id,
                            uid,
                          ),
                          onSeatTap: isCreator && room != null
                              ? (uid) => _onOccupiedSeatTap(room, uid)
                              : null,
                          // Empty top seat = a free spot on the local team.
                          onEmptySeatTap: isCreator && room != null
                              ? () => _onEmptySeatTap(room, localTeam ?? 'A')
                              : null,
                          isSelected:
                              _selectedSeatUid != null &&
                              partner?.uid == _selectedSeatUid,
                          selectionActive: _selectedSeatUid != null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // VS indicator
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: ColorManager.secondary.withValues(
                              alpha: 0.15,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ColorManager.secondary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'vs'.tr(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: ColorManager.secondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Opponents (opposite team) left and right
                        Row(
                          children: [
                            Expanded(
                              child: SeatWidget(
                                player: opponentLeft,
                                label: LocaleKeys.opponent_1.tr(),
                                position: SeatPosition.left,
                                isCreator: isCreator,
                                inviteCode: room?.inviteCode,
                                onKick: (uid) => context
                                    .read<RoomCubit>()
                                    .kickPlayer(room!.id, uid),
                                onSeatTap: isCreator && room != null
                                    ? (uid) => _onOccupiedSeatTap(room, uid)
                                    : null,
                                // Empty side seat = a free spot on the
                                // opposing team.
                                onEmptySeatTap: isCreator && room != null
                                    ? () => _onEmptySeatTap(
                                        room,
                                        localTeam == 'A' ? 'B' : 'A',
                                      )
                                    : null,
                                isSelected:
                                    _selectedSeatUid != null &&
                                    opponentLeft?.uid == _selectedSeatUid,
                                selectionActive: _selectedSeatUid != null,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: SeatWidget(
                                player: opponentRight,
                                label: LocaleKeys.opponent_2.tr(),
                                position: SeatPosition.right,
                                isCreator: isCreator,
                                inviteCode: room?.inviteCode,
                                onKick: (uid) => context
                                    .read<RoomCubit>()
                                    .kickPlayer(room!.id, uid),
                                onSeatTap: isCreator && room != null
                                    ? (uid) => _onOccupiedSeatTap(room, uid)
                                    : null,
                                onEmptySeatTap: isCreator && room != null
                                    ? () => _onEmptySeatTap(
                                        room,
                                        localTeam == 'A' ? 'B' : 'A',
                                      )
                                    : null,
                                isSelected:
                                    _selectedSeatUid != null &&
                                    opponentRight?.uid == _selectedSeatUid,
                                selectionActive: _selectedSeatUid != null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // You at bottom — always show the current user in the
                        // bottom seat, not whoever sits at index 0.
                        SeatWidget(
                          player: localPlayer,
                          label: LocaleKeys.you.tr(),
                          position: SeatPosition.bottom,
                          isCreator: isCreator,
                          inviteCode: room?.inviteCode,
                          onKick: (uid) => context.read<RoomCubit>().kickPlayer(
                            room!.id,
                            uid,
                          ),
                          onSeatTap: isCreator && room != null
                              ? (uid) => _onOccupiedSeatTap(room, uid)
                              : null,
                          isSelected:
                              _selectedSeatUid != null &&
                              localPlayer?.uid == _selectedSeatUid,
                          selectionActive: _selectedSeatUid != null,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        // Room Settings section
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: ColorManager.darkSurface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color: ColorManager.darkBorderSoft,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'room_settings'.tr(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: ColorManager.darkTextPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _buildSettingRow(
                                Icons.mic_rounded,
                                'voice_chat'.tr(),
                                room?.voiceEnabled == true
                                    ? LocaleKeys.labelOn.tr()
                                    : 'off'.tr(),
                              ),
                              const Divider(
                                color: ColorManager.darkBorderSoft,
                                height: 16,
                              ),
                              _buildSettingRow(
                                Icons.videocam_rounded,
                                'camera'.tr(),
                                room?.cameraEnabled == true
                                    ? LocaleKeys.labelOn.tr()
                                    : 'off'.tr(),
                              ),
                              const Divider(
                                color: ColorManager.darkBorderSoft,
                                height: 16,
                              ),
                              _buildSettingRow(
                                Icons.visibility_rounded,
                                'spectators'.tr(),
                                room?.allowSpectators == true
                                    ? 'allowed'.tr()
                                    : 'not_allowed'.tr(),
                              ),
                              const Divider(
                                color: ColorManager.darkBorderSoft,
                                height: 16,
                              ),
                              _buildSettingRow(
                                Icons.meeting_room_rounded,
                                'room_type'.tr(),
                                room?.type.name.tr() ?? 'private'.tr(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        // Ready indicator
                        Text(
                          '$readyCount/4 ${'ready'.tr()}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: ColorManager.darkTextSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Mic / Camera toggles (you only) — shown only for
                        // rooms created with voice/camera enabled.
                        if (room?.voiceEnabled == true ||
                            room?.cameraEnabled == true)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (room?.voiceEnabled == true) ...[
                                _MediaToggleButton(
                                  key: const Key('media_toggle_mic'),
                                  icon:
                                      room?.players.any(
                                            (p) => p.isMe && p.isMicOn,
                                          ) ==
                                          true
                                      ? Icons.mic_rounded
                                      : Icons.mic_off_rounded,
                                  color:
                                      room?.players.any(
                                            (p) => p.isMe && p.isMicOn,
                                          ) ==
                                          true
                                      ? ColorManager.success
                                      : ColorManager.error,
                                  onTap: room != null
                                      ? () => context
                                            .read<RoomCubit>()
                                            .toggleMic(room.id)
                                      : null,
                                ),
                                const SizedBox(width: AppSpacing.lg),
                              ],
                              if (room?.cameraEnabled == true)
                                _MediaToggleButton(
                                  key: const Key('media_toggle_camera'),
                                  icon:
                                      room?.players.any(
                                            (p) => p.isMe && p.isCameraOn,
                                          ) ==
                                          true
                                      ? Icons.videocam_rounded
                                      : Icons.videocam_off_rounded,
                                  color:
                                      room?.players.any(
                                            (p) => p.isMe && p.isCameraOn,
                                          ) ==
                                          true
                                      ? ColorManager.success
                                      : ColorManager.darkTextMuted,
                                  onTap: room != null
                                      ? () => context
                                            .read<RoomCubit>()
                                            .toggleCamera(room.id)
                                      : null,
                                ),
                            ],
                          ),
                        const SizedBox(height: AppSpacing.md),
                        // Stream controls (creator only)
                        if (isCreator &&
                            (room?.type == RoomType.public ||
                                room?.type == RoomType.liveStream))
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: room?.isStreaming == true
                                ? Row(
                                    children: [
                                      Expanded(child: _StreamingLiveBadge()),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: AppButton(
                                          text: 'end_stream'.tr(),
                                          isOutlined: true,
                                          onPressed: () => context
                                              .read<RoomCubit>()
                                              .endStream(room!.id),
                                        ),
                                      ),
                                    ],
                                  )
                                : AppButton(
                                    text: 'go_live'.tr(),
                                    gradient: const LinearGradient(
                                      colors: [
                                        ColorManager.live,
                                        ColorManager.live,
                                      ],
                                    ),
                                    onPressed: () => context
                                        .read<RoomCubit>()
                                        .startStream(room!.id),
                                  ),
                          ),
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                text: isReady
                                    ? 'not_ready'.tr()
                                    : 'i_am_ready'.tr(),
                                isOutlined: isReady,
                                // Spectators watching the lobby can't ready
                                // up — the backend would reject it with
                                // "Player not in room".
                                onPressed: room != null && isParticipant
                                    ? () => context
                                          .read<RoomCubit>()
                                          .toggleReady(room.id)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: AppButton(
                                text: isCreator
                                    ? (allReady
                                          ? 'start_game'.tr()
                                          : '${'ready'.tr()} $readyCount/4')
                                    : 'start_game'.tr(),
                                onPressed: allReady && isCreator
                                    ? () => context.read<RoomCubit>().startGame(
                                        room!.id,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Invite bots to fill empty seats (creator only)
                        if (room != null &&
                            room.status == RoomStatus.waiting &&
                            isCreator &&
                            players.length < 4)
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              text: 'invite_bots'.tr(),
                              isOutlined: true,
                              onPressed: () => context
                                  .read<RoomCubit>()
                                  .inviteBotsToRoom(room.id),
                            ),
                          ),
                        if (room != null &&
                            room.status == RoomStatus.waiting &&
                            isCreator &&
                            players.length < 4)
                          const SizedBox(height: AppSpacing.md),
                        if (room != null &&
                            room.status == RoomStatus.waiting &&
                            isCreator &&
                            players.length < 4)
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              text: 'invite_friend'.tr(),
                              icon: Icons.person_add_rounded,
                              onPressed: () {
                                final roomCubit = context.read<RoomCubit>();
                                showModalBottomSheet<void>(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true,
                                  builder: (_) => BlocProvider.value(
                                    value: roomCubit,
                                    child: InviteFriendSheet(roomId: room.id),
                                  ),
                                );
                              },
                            ),
                          ),
                        if (room != null &&
                            room.status == RoomStatus.waiting &&
                            isCreator &&
                            players.length < 4)
                          const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: ColorManager.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: ColorManager.darkTextPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorManager.primary,
          ),
        ),
      ],
    );
  }

  /// Creator team management: first tap selects a seat, second tap on an
  /// occupied seat of the other team asks to swap the two players.
  void _onOccupiedSeatTap(Room room, String tappedUid) {
    final selectedUid = _selectedSeatUid;
    if (selectedUid == null) {
      setState(() => _selectedSeatUid = tappedUid);
      return;
    }
    if (selectedUid == tappedUid) {
      setState(() => _selectedSeatUid = null);
      return;
    }
    RoomPlayer? first;
    RoomPlayer? second;
    for (final p in room.players) {
      if (p.uid == selectedUid) first = p;
      if (p.uid == tappedUid) second = p;
    }
    // Selected player left the room, or the tapped seat is on the same team
    // (swap would be a no-op) — just move the selection instead.
    if (first == null || second == null || first.team == second.team) {
      setState(() => _selectedSeatUid = tappedUid);
      return;
    }
    setState(() => _selectedSeatUid = null);
    _showSwapConfirm(room, first, second);
  }

  /// Creator team management: tapping an empty seat while a player is
  /// selected asks to move that player to the seat's team.
  void _onEmptySeatTap(Room room, String targetTeam) {
    final selectedUid = _selectedSeatUid;
    if (selectedUid == null) return;
    RoomPlayer? selected;
    for (final p in room.players) {
      if (p.uid == selectedUid) {
        selected = p;
        break;
      }
    }
    setState(() => _selectedSeatUid = null);
    if (selected == null || selected.team == targetTeam) return;
    _showMoveConfirm(room, selected, targetTeam);
  }

  void _showSwapConfirm(Room room, RoomPlayer first, RoomPlayer second) {
    final roomCubit = context.read<RoomCubit>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ColorManager.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          LocaleKeys.swap_players.tr(),
          style: const TextStyle(color: ColorManager.darkTextPrimary),
        ),
        content: Text(
          LocaleKeys.swap_players_confirm.tr(
            namedArgs: {'nameA': first.name, 'nameB': second.name},
          ),
          style: const TextStyle(color: ColorManager.darkTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              dialogContext.pop();
              roomCubit.swapPlayerTeams(room.id, first.uid, second.uid);
            },
            child: Text(
              LocaleKeys.swap_players.tr(),
              style: const TextStyle(color: ColorManager.info),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoveConfirm(Room room, RoomPlayer player, String targetTeam) {
    final roomCubit = context.read<RoomCubit>();
    RoomPlayer? localPlayer;
    for (final p in room.players) {
      if (p.isMe) {
        localPlayer = p;
        break;
      }
    }
    final isYourTeam = localPlayer?.team == targetTeam;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ColorManager.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          LocaleKeys.move_to_team.tr(),
          style: const TextStyle(color: ColorManager.darkTextPrimary),
        ),
        content: Text(
          (isYourTeam
                  ? LocaleKeys.move_to_your_team_confirm
                  : LocaleKeys.move_to_opposing_team_confirm)
              .tr(namedArgs: {'name': player.name}),
          style: const TextStyle(color: ColorManager.darkTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              dialogContext.pop();
              roomCubit.movePlayerToTeam(room.id, player.uid, targetTeam);
            },
            child: Text(
              LocaleKeys.move_to_team.tr(),
              style: const TextStyle(color: ColorManager.info),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: ColorManager.darkSectionGray,
          borderRadius: BorderRadius.circular(AppRadius.iconContainer),
        ),
        child: Icon(icon, size: 18, color: ColorManager.darkTextSecondary),
      ),
    );
  }
}

class _MediaToggleButton extends StatelessWidget {
  const _MediaToggleButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: ColorManager.darkSurface,
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

/// Pulsing red LIVE badge for streaming indicator.
class _StreamingLiveBadge extends StatefulWidget {
  @override
  State<_StreamingLiveBadge> createState() => _StreamingLiveBadgeState();
}

class _StreamingLiveBadgeState extends State<_StreamingLiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 52,
          decoration: BoxDecoration(
            color: ColorManager.live.withValues(alpha: _animation.value * 0.9),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.circle,
                size: 8,
                color: ColorManager.darkTextPrimary,
              ),
              const SizedBox(width: 6),
              Text(
                'streaming_live'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: ColorManager.darkTextPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
