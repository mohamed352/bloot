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
  })  : _roomRepository = roomRepository,
        _agoraService = agoraService,
        super(const RoomState.initial());

  final RoomRepository _roomRepository;
  final AgoraService _agoraService;
  StreamSubscription<Room>? _roomSubscription;
  StreamSubscription<List<Room>>? _publicRoomsSubscription;
  StreamSubscription<List<RoomChatMessage>>? _chatSubscription;
  StreamSubscription<AgoraAudioVolumeIndicationEvent>?
      _audioVolumeSubscription;
  Room? _currentRoom;
  List<RoomChatMessage> _chatMessages = [];
  bool _chatOpen = false;
  String? _joinedAgoraChannelName;
  Future<void>? _pendingAgoraJoin;
  bool _gameStartedEmitted = false;

  void _emitMergedState() {
    final room = _currentRoom;
    if (room == null) return;
    emit(
      RoomState.loaded(
        room: room.copyWith(chatMessages: _chatMessages),
        chatOpen: _chatOpen,
      ),
    );
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
  /// the game immediately.
  Future<void> createRoomWithBots() async {
    emit(const RoomState.loading());
    try {
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

  void loadRoom(String roomId) {
    emit(const RoomState.loading());
    _roomSubscription?.cancel();
    _chatSubscription?.cancel();
    _audioVolumeSubscription?.cancel();
    _currentRoom = null;
    _chatMessages = [];
    _gameStartedEmitted = false;

    _roomSubscription = _roomRepository.watchRoom(roomId).listen(
      (room) {
        _currentRoom = room;

        // Auto-navigate when game starts, but only once per room session.
        if (room.status == RoomStatus.playing &&
            room.gameId != null &&
            !_gameStartedEmitted) {
          _gameStartedEmitted = true;
          emit(RoomState.gameStarted(gameId: room.gameId!));
          return;
        }

        _emitMergedState();

        // Auto-join Agora voice channel once per channel name change.
        // Only actual room participants should join voice; spectators should not.
        final isParticipant = room.players.any((p) => p.isMe);
        final agoraChannelName = room.agoraChannelName ?? 'room_${room.id}';
        if (isParticipant &&
            (room.voiceEnabled || room.cameraEnabled) &&
            _joinedAgoraChannelName != agoraChannelName &&
            _pendingAgoraJoin == null) {
          final pendingJoin = _agoraService.joinChannel(channelName: agoraChannelName);
          _pendingAgoraJoin = pendingJoin;
          pendingJoin.then((_) {
            if (isClosed) return;
            _joinedAgoraChannelName = agoraChannelName;
            _listenToAudioVolume(room);
          }).catchError((Object e) {
            AppLogger.error('Failed to join Agora', error: e);
          }).whenComplete(() {
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

    _chatSubscription = _roomRepository.watchChatMessages(roomId).listen(
      (messages) {
        _chatMessages = messages;
        _emitMergedState();
      },
      onError: (Object error) {
        AppLogger.error('Chat stream error', error: error);
      },
    );
  }

  void _listenToAudioVolume(Room room) {
    _audioVolumeSubscription?.cancel();
    _audioVolumeSubscription =
        _agoraService.onAudioVolumeIndication.listen((event) {
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

  Future<void> joinRoomByCode(
    String inviteCode, {
    String? password,
  }) async {
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
      emit(const RoomState.error(message: 'Failed to start game. Please try again.'));
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

  void toggleChat() {
    _chatOpen = !_chatOpen;
    _emitMergedState();
  }

  Future<void> sendChatMessage(String roomId, String message) async {
    final currentState = state;
    if (currentState is! RoomLoaded) return;
    if (message.trim().isEmpty) return;
    try {
      await _roomRepository.sendChatMessage(roomId, message.trim());
      // Real-time listener will update chat messages automatically
    } on RoomException catch (e) {
      emit(RoomState.error(message: e.message));
      emit(currentState);
    } catch (e) {
      AppLogger.error('Failed to send message', error: e);
      emit(
        const RoomState.error(
          message: 'Failed to send message. Please try again.',
        ),
      );
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

  Future<void> leaveRoom(String roomId) async {
    final currentState = state;
    if (currentState is! RoomLoaded) return;

    try {
      await _roomRepository.leaveRoom(roomId);
      await _agoraService.leaveChannel();
      // Stop listening to the room before emitting the initial state so a
      // deleted/empty room does not surface a ROOM_NOT_FOUND error after exit.
      await _roomSubscription?.cancel();
      _roomSubscription = null;
      await _chatSubscription?.cancel();
      _chatSubscription = null;
      await _audioVolumeSubscription?.cancel();
      _audioVolumeSubscription = null;
      _joinedAgoraChannelName = null;
      emit(const RoomState.initial());
    } on RoomException catch (e) {
      emit(RoomState.error(message: e.message));
      emit(currentState);
    } catch (e) {
      AppLogger.error('Failed to leave room', error: e);
      emit(const RoomState.error(message: 'Failed to leave room. Please try again.'));
      emit(currentState);
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
      emit(const RoomState.error(message: 'Failed to kick player. Please try again.'));
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
      emit(const RoomState.error(message: 'Failed to start stream. Please try again.'));
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
      emit(const RoomState.error(message: 'Failed to end stream. Please try again.'));
      emit(currentState);
    }
  }

  @override
  Future<void> close() async {
    await _roomSubscription?.cancel();
    await _publicRoomsSubscription?.cancel();
    await _chatSubscription?.cancel();
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
