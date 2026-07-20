import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/core/services/agora_service.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/features/room/domain/exceptions/room_exception.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';
import 'package:bloot/features/room/presentation/cubit/room_state.dart';

@injectable
class RoomCubit extends Cubit<RoomState> {
  RoomCubit({
    required RoomRepository roomRepository,
    required AgoraService agoraService,
  }) : _roomRepository = roomRepository,
       _agoraService = agoraService,
       super(const RoomState.initial());

  final RoomRepository _roomRepository;
  final AgoraService _agoraService;
  StreamSubscription<Room>? _roomSubscription;
  StreamSubscription<List<Room>>? _publicRoomsSubscription;
  StreamSubscription<AgoraAudioVolumeIndicationEvent>? _audioVolumeSubscription;
  Room? _currentRoom;
  String? _joinedAgoraChannelName;
  Future<void>? _pendingAgoraJoin;
  bool _gameStartedEmitted = false;

  /// Host-side stream heartbeat: while the local user hosts an active
  /// stream, this timer touches `lastHeartbeatAt` every minute so the
  /// server sweeper can end the broadcast if the app dies unexpectedly.
  Timer? _streamHeartbeatTimer;
  String? _streamHeartbeatId;

  void _syncStreamHeartbeat(Room room) {
    final isHost =
        room.creatorUid != null &&
        room.players.any((p) => p.isMe && p.uid == room.creatorUid);
    final streamId = room.streamId;
    final shouldBeat =
        room.isStreaming && isHost && streamId != null && streamId.isNotEmpty;

    if (!shouldBeat) {
      _streamHeartbeatTimer?.cancel();
      _streamHeartbeatTimer = null;
      _streamHeartbeatId = null;
      return;
    }
    if (_streamHeartbeatId == streamId) return; // already beating
    _streamHeartbeatId = streamId;
    _streamHeartbeatTimer?.cancel();
    // First beat immediately, then once a minute. Best-effort: failures are
    // swallowed so a heartbeat can never crash the room session.
    unawaited(_safeHeartbeat(streamId));
    _streamHeartbeatTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      unawaited(_safeHeartbeat(streamId));
    });
  }

  Future<void> _safeHeartbeat(String streamId) async {
    try {
      await _roomRepository.sendStreamHeartbeat(streamId);
    } catch (e) {
      AppLogger.error('Stream heartbeat failed', error: e);
    }
  }

  /// Whether the local user was a participant in the last room snapshot.
  /// Used to detect that the host removed (kicked) the local user.
  bool _wasLocalParticipant = false;

  void _emitMergedState() {
    final room = _currentRoom;
    if (room == null) return;
    emit(RoomState.loaded(room: room));
  }

  void watchPublicRooms() {
    emit(const RoomState.loading());
    _publicRoomsSubscription?.cancel();

    _publicRoomsSubscription = _roomRepository.watchPublicRooms().listen(
      (rooms) {
        emit(RoomState.publicListLoaded(rooms: rooms));
      },
      onError: (Object error) {
        AppLogger.error('Public rooms stream error', error: error);
        emit(
          const RoomState.error(
            message: 'Failed to load public rooms. Please try again.',
          ),
        );
      },
    );
  }

  Future<void> createRoom(CreateRoomParams params) async {
    emit(const RoomState.loading());
    try {
      final room = await _roomRepository.createRoom(params);
      emit(RoomState.created(room: room));
    } on RoomException catch (e) {
      emit(RoomState.error(message: e.message));
    } catch (e) {
      AppLogger.error('Failed to create room', error: e);
      emit(
        const RoomState.error(
          message: 'Failed to create room. Please try again.',
        ),
      );
    }
  }

  /// Creates a real room with the current user plus 3 bot players, then starts
  /// the game immediately. Leaves any room the user is currently in first so a
  /// previous live/lobby doesn't linger without its host.
  Future<void> createRoomWithBots() async {
    emit(const RoomState.loading());
    try {
      final activeRoom = _currentRoom;
      if (activeRoom != null) {
        try {
          await _roomRepository.leaveRoom(activeRoom.id);
        } catch (e) {
          AppLogger.error('Failed to leave room before bot game', error: e);
        }
        _currentRoom = null;
        await _agoraService.leaveChannel();
        _joinedAgoraChannelName = null;
      }
      final result = await _roomRepository.createRoomWithBots();
      _gameStartedEmitted = true;
      emit(RoomState.gameStarted(gameId: result.gameId));
    } on RoomException catch (e) {
      emit(RoomState.error(message: e.message));
    } catch (e) {
      AppLogger.error('Failed to create bot room', error: e);
      emit(
        const RoomState.error(
          message: 'Failed to start game with bots. Please try again.',
        ),
      );
    }
  }

  /// Invites bots to fill empty seats in the current room. If the room becomes
  /// full, the game starts automatically.
  Future<void> inviteBotsToRoom(String roomId) async {
    final currentState = state;
    if (currentState is! RoomLoaded) return;
    try {
      final result = await _roomRepository.inviteBotsToRoom(roomId);
      if (result.gameId != null && !_gameStartedEmitted) {
        _gameStartedEmitted = true;
        emit(RoomState.gameStarted(gameId: result.gameId!));
      }
    } on RoomException catch (e) {
      emit(RoomState.error(message: e.message));
      emit(currentState);
    } catch (e) {
      AppLogger.error('Failed to invite bots', error: e);
      emit(
        const RoomState.error(
          message: 'Failed to invite bots. Please try again.',
        ),
      );
      emit(currentState);
    }
  }

  void loadRoom(String roomId) {
    emit(const RoomState.loading());
    _roomSubscription?.cancel();
    _audioVolumeSubscription?.cancel();
    _currentRoom = null;
    _gameStartedEmitted = false;
    _wasLocalParticipant = false;
    AppLogger.setCustomKey('roomId', roomId);

    _roomSubscription = _roomRepository
        .watchRoom(roomId)
        .listen(
          (room) async {
            // If a previous snapshot had the local user as a participant and
            // this one does not, the host removed them: treat it as a kick.
            final isParticipant = room.players.any((p) => p.isMe);
            if (_wasLocalParticipant && !isParticipant) {
              await _handleKicked();
              return;
            }
            _wasLocalParticipant = isParticipant;
            _currentRoom = room;
            _syncStreamHeartbeat(room);

            // Auto-navigate when game starts, but only once per room session.
            if (room.status == RoomStatus.playing &&
                room.gameId != null &&
                !_gameStartedEmitted) {
              _gameStartedEmitted = true;
              AppLogger.setCustomKey('gameId', room.gameId);
              emit(RoomState.gameStarted(gameId: room.gameId!));
              return;
            }

            _emitMergedState();

            // Auto-join Agora voice channel once per channel name change.
            // Only actual room participants should join voice; spectators should not.
            final agoraChannelName = room.agoraChannelName ?? 'room_${room.id}';
            if (isParticipant &&
                (room.voiceEnabled || room.cameraEnabled) &&
                _joinedAgoraChannelName != agoraChannelName &&
                _pendingAgoraJoin == null) {
              final localPlayer = room.players.firstWhere(
                (p) => p.isMe,
                orElse: () => room.players.first,
              );
              final pendingJoin = _agoraService.joinChannel(
                channelName: agoraChannelName,
                agoraUid: localPlayer.agoraUid,
              );
              _pendingAgoraJoin = pendingJoin;
              pendingJoin
                  .then((_) async {
                    // A kick/reload can clear the current room while the join
                    // is in flight; never mark that stale join as active.
                    if (isClosed || _currentRoom == null) return;
                    _joinedAgoraChannelName = agoraChannelName;
                    _listenToAudioVolume(room);
                    // Sync the Agora engine with the Firestore media flags.
                    // The room doc defaults isCameraOn=true for camera rooms,
                    // but the engine starts with the camera off and never
                    // publishes a video track unless explicitly enabled,
                    // which showed a black screen to everyone.
                    try {
                      await _agoraService.setMediaState(
                        micOn: localPlayer.isMicOn,
                        cameraOn:
                            room.cameraEnabled && localPlayer.isCameraOn,
                      );
                    } catch (e) {
                      AppLogger.error('Failed to sync media state', error: e);
                    }
                  })
                  .catchError((Object e) {
                    AppLogger.error('Failed to join Agora', error: e);
                  })
                  .whenComplete(() {
                    _pendingAgoraJoin = null;
                  });
            }
          },
          onError: (Object error) {
            AppLogger.error('Room stream error', error: error);
            if (error is RoomException) {
              emit(RoomState.error(message: error.message));
            } else {
              emit(
                const RoomState.error(
                  message: 'Failed to load room. Please try again.',
                ),
              );
            }
          },
        );
  }

  /// Cleans up local room/audio/Agora state after the local user was removed
  /// from the room by the host, then emits [RoomState.kicked].
  ///
  /// Unlike [leaveRoom], this never calls the repository: the backend already
  /// removed the player, so calling `leaveRoom` would fail or kick no one.
  Future<void> _handleKicked() async {
    AppLogger.info('Local user was removed from the room', tag: 'Room');
    _wasLocalParticipant = false;
    _currentRoom = null;

    // Do not await cancellation of the subscription whose listener is calling
    // us; that can deadlock on some stream implementations. AgoraService also
    // handles a leave request that arrives while a join is still in flight.
    final roomSubscription = _roomSubscription;
    _roomSubscription = null;
    unawaited(roomSubscription?.cancel());

    final audioSubscription = _audioVolumeSubscription;
    _audioVolumeSubscription = null;
    unawaited(audioSubscription?.cancel());

    _pendingAgoraJoin = null;
    unawaited(_agoraService.leaveChannel());
    _joinedAgoraChannelName = null;

    if (!isClosed) emit(const RoomState.kicked());
  }

  void _listenToAudioVolume(Room room) {
    _audioVolumeSubscription?.cancel();
    _audioVolumeSubscription = _agoraService.onAudioVolumeIndication.listen((
      event,
    ) {
      if (_currentRoom == null) return;

      final speakingUids = event.speakers
          .where((s) => s.volume != null && s.volume! > 50)
          .map((s) => s.uid)
          .toSet();

      final updatedPlayers = _currentRoom!.players.map((player) {
        final isSpeaking =
            player.agoraUid != null && speakingUids.contains(player.agoraUid);
        if (player.isSpeaking != isSpeaking) {
          return player.copyWith(isSpeaking: isSpeaking);
        }
        return player;
      }).toList();

      final hasChanges = updatedPlayers.indexed.any(
        (e) => e.$2.isSpeaking != _currentRoom!.players[e.$1].isSpeaking,
      );

      if (hasChanges) {
        _currentRoom = _currentRoom!.copyWith(players: updatedPlayers);
        _emitMergedState();
      }
    });
  }

  Future<bool> isPasswordRequired(String inviteCode) async {
    try {
      return await _roomRepository.isPasswordRequired(inviteCode);
    } catch (e) {
      AppLogger.error('Failed to check password requirement', error: e);
      return false;
    }
  }

  Future<void> joinRoomByCode(String inviteCode, {String? password}) async {
    emit(const RoomState.loading());
    try {
      final room = await _roomRepository.joinRoomByCode(
        inviteCode,
        password: password,
      );
      emit(RoomState.created(room: room));
    } on RoomException catch (e) {
      emit(RoomState.error(message: e.message));
    } catch (e) {
      AppLogger.error('Failed to join room', error: e);
      emit(
        const RoomState.error(
          message: 'Failed to join room. Please check the code and try again.',
        ),
      );
    }
  }

  Future<void> startGame(String roomId) async {
    final currentState = state;
    emit(const RoomState.loading());
    try {
      final gameId = await _roomRepository.startGame(roomId);
      // Navigate immediately. The stream listener is guarded by
      // [_gameStartedEmitted] so it will not push a second GamePlayPage.
      if (!_gameStartedEmitted) {
        _gameStartedEmitted = true;
        emit(RoomState.gameStarted(gameId: gameId));
      }
    } on RoomException catch (e) {
      emit(RoomState.error(message: e.message));
      if (currentState is RoomLoaded) emit(currentState);
    } catch (e) {
      AppLogger.error('Failed to start game', error: e);
      emit(
        const RoomState.error(
          message: 'Failed to start game. Please try again.',
        ),
      );
      if (currentState is RoomLoaded) emit(currentState);
    }
  }

  Future<void> toggleReady(String roomId) async {
    final currentState = state;
    if (currentState is! RoomLoaded) return;
    try {
      await _roomRepository.toggleReady(roomId);
      // Real-time listener will update the state automatically
    } on RoomException catch (e) {
      emit(RoomState.error(message: e.message));
      emit(currentState);
    } catch (e) {
      AppLogger.error('Failed to toggle ready', error: e);
      emit(const RoomState.error(message: 'Failed to update ready status.'));
      emit(currentState);
    }
  }

  Future<void> toggleMic(String roomId) async {
    final currentState = state;
    if (currentState is! RoomLoaded) return;

    try {
      final isMicOn = await _agoraService.toggleMic();
      await _roomRepository.updatePlayerMediaState(
        roomId,
        isMicOn: isMicOn,
        isCameraOn: _agoraService.isCameraOn,
      );
      // Real-time listener updates UI
    } on RoomException catch (e) {
      emit(RoomState.error(message: e.message));
      emit(currentState);
    } catch (e) {
      AppLogger.error('Failed to toggle mic', error: e);
      emit(const RoomState.error(message: 'Failed to toggle microphone.'));
      emit(currentState);
    }
  }

  Future<void> toggleCamera(String roomId) async {
    final currentState = state;
    if (currentState is! RoomLoaded) return;

    try {
      final isCameraOn = await _agoraService.toggleCamera();
      await _roomRepository.updatePlayerMediaState(
        roomId,
        isMicOn: _agoraService.isMicOn,
        isCameraOn: isCameraOn,
      );
      // Real-time listener updates UI
    } on RoomException catch (e) {
      emit(RoomState.error(message: e.message));
      emit(currentState);
    } catch (e) {
      AppLogger.error('Failed to toggle camera', error: e);
      emit(const RoomState.error(message: 'Failed to toggle camera.'));
      emit(currentState);
    }
  }

  /// Returns `true` when the leave actually succeeded on the backend, so
  /// callers can decide whether to navigate away or stay and let the user
  /// retry (previously the UI popped even when the leave call failed,
  /// leaving the player stuck in the room server-side).
  Future<bool> leaveRoom(String roomId) async {
    final currentState = state;
    if (currentState is! RoomLoaded) return false;

    try {
      // Stop listening first so a late room update does not re-trigger Agora join.
      await _roomSubscription?.cancel();
      _roomSubscription = null;
      await _audioVolumeSubscription?.cancel();
      _audioVolumeSubscription = null;

      // Wait for an in-flight Agora join to finish before leaving.
      if (_pendingAgoraJoin != null) {
        try {
          await _pendingAgoraJoin!.timeout(const Duration(seconds: 3));
        } catch (_) {
          // Ignore join errors/timeouts during leave.
        }
        _pendingAgoraJoin = null;
      }

      await _roomRepository.leaveRoom(roomId);
      await _agoraService.leaveChannel();
      _joinedAgoraChannelName = null;
      _currentRoom = null;
      _streamHeartbeatTimer?.cancel();
      _streamHeartbeatTimer = null;
      _streamHeartbeatId = null;
      if (!isClosed) emit(const RoomState.initial());
      return true;
    } on RoomException catch (e) {
      AppLogger.error('Failed to leave room', error: e.message);
      if (!isClosed) {
        emit(RoomState.error(message: e.message));
        emit(currentState);
      }
      return false;
    } catch (e) {
      AppLogger.error('Failed to leave room', error: e);
      if (!isClosed) {
        emit(
          const RoomState.error(
            message: 'Failed to leave room. Please try again.',
          ),
        );
        emit(currentState);
      }
      return false;
    }
  }

  Future<void> kickPlayer(String roomId, String targetUid) async {
    final currentState = state;
    if (currentState is! RoomLoaded) return;

    try {
      await _roomRepository.kickPlayer(roomId, targetUid);
      // Real-time listener updates UI
    } on RoomException catch (e) {
      emit(RoomState.error(message: e.message));
      emit(currentState);
    } catch (e) {
      AppLogger.error('Failed to kick player', error: e);
      emit(
        const RoomState.error(
          message: 'Failed to kick player. Please try again.',
        ),
      );
      emit(currentState);
    }
  }

  Future<void> startStream(String roomId) async {
    final currentState = state;
    if (currentState is! RoomLoaded) return;

    try {
      await _roomRepository.startStream(roomId);
      // Real-time listener updates UI with isStreaming=true
    } catch (e) {
      AppLogger.error('Failed to start stream', error: e);
      emit(
        const RoomState.error(
          message: 'Failed to start stream. Please try again.',
        ),
      );
      emit(currentState);
    }
  }

  Future<void> endStream(String roomId) async {
    final currentState = state;
    if (currentState is! RoomLoaded) return;

    try {
      await _roomRepository.endStream(roomId);
      // Real-time listener updates UI with isStreaming=false
    } catch (e) {
      AppLogger.error('Failed to end stream', error: e);
      emit(RoomState.error(message: e.toString()));
      emit(currentState);
    }
  }

  Future<bool> sendRoomInvite(String roomId, String friendUid) async {
    try {
      await _roomRepository
          .sendRoomInvite(roomId, friendUid)
          .timeout(const Duration(seconds: 15));
      return true;
    } on RoomException catch (e) {
      AppLogger.error('Failed to send room invite', error: e.message);
      return false;
    } catch (e) {
      AppLogger.error('Failed to send room invite', error: e);
      return false;
    }
  }

  @override
  Future<void> close() async {
    _streamHeartbeatTimer?.cancel();
    _streamHeartbeatTimer = null;
    _streamHeartbeatId = null;
    await _roomSubscription?.cancel();
    await _publicRoomsSubscription?.cancel();
    await _audioVolumeSubscription?.cancel();
    // Wait for an in-flight Agora join to finish before leaving so we don't
    // call leaveChannel while joinChannel is still running.
    if (_pendingAgoraJoin != null) {
      try {
        await _pendingAgoraJoin!.timeout(const Duration(seconds: 3));
      } catch (_) {
        // Ignore join errors/timeouts during close.
      }
      _pendingAgoraJoin = null;
    }
    // Only leave Agora if this cubit actually joined a channel.
    if (_joinedAgoraChannelName != null) {
      await _agoraService.leaveChannel();
      _joinedAgoraChannelName = null;
    }
    return super.close();
  }
}
