import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/features/room/data/datasources/room_remote_data_source.dart';
import 'package:bloot/features/room/data/models/room_model.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';

@LazySingleton(as: RoomRepository)
class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl({
    required RoomRemoteDataSource remoteDataSource,
    required FirebaseAuth firebaseAuth,
  }) : _remoteDataSource = remoteDataSource,
       _firebaseAuth = firebaseAuth;

  final RoomRemoteDataSource _remoteDataSource;
  final FirebaseAuth _firebaseAuth;

  String? get _currentUid => _firebaseAuth.currentUser?.uid;

  @override
  Future<Room> createRoom(CreateRoomParams params) async {
    final model = await _remoteDataSource.createRoom(
      name: params.name,
      type: params.type.name,
      voiceEnabled: params.voiceEnabled,
      cameraEnabled: params.cameraEnabled,
      allowSpectators: params.allowSpectators,
      gameSpeed: 'normal',
      password: params.password,
    );
    return model.toEntity(currentUserUid: _currentUid);
  }

  @override
  Stream<Room> watchRoom(String id) {
    return _remoteDataSource
        .watchRoom(id)
        .map((model) => model.toEntity(currentUserUid: _currentUid));
  }

  @override
  Stream<List<Room>> watchPublicRooms() {
    return _remoteDataSource.watchPublicRooms().map(
      (models) =>
          models.map((m) => m.toEntity(currentUserUid: _currentUid)).toList(),
    );
  }

  @override
  Future<Room> getRoomById(String id) async {
    final model = await _remoteDataSource.getRoomById(id);
    return model.toEntity(currentUserUid: _currentUid);
  }

  @override
  Future<Room> toggleReady(String roomId) async {
    final model = await _remoteDataSource.toggleReady(roomId);
    return model.toEntity(currentUserUid: _currentUid);
  }

  @override
  Future<void> updatePlayerMediaState(
    String roomId, {
    required bool isMicOn,
    required bool isCameraOn,
  }) async {
    await _remoteDataSource.updatePlayerMediaState(
      roomId,
      isMicOn: isMicOn,
      isCameraOn: isCameraOn,
    );
  }

  @override
  Future<bool> isPasswordRequired(String inviteCode) =>
      _remoteDataSource.isPasswordRequired(inviteCode);

  @override
  Future<Room> joinRoomByCode(String inviteCode, {String? password}) async {
    final model = await _remoteDataSource.joinRoomByCode(
      inviteCode,
      password: password,
    );
    return model.toEntity(currentUserUid: _currentUid);
  }

  @override
  Future<Room> joinRoomById(String roomId, {String? password}) async {
    final model = await _remoteDataSource.joinRoomById(
      roomId,
      password: password,
    );
    return model.toEntity(currentUserUid: _currentUid);
  }

  @override
  Future<String> startGame(String roomId) async {
    return _remoteDataSource.startGame(roomId);
  }

  @override
  Future<({String roomId, String gameId})> createRoomWithBots() async {
    return _remoteDataSource.createRoomWithBots();
  }

  @override
  Future<({String roomId, String? gameId})> inviteBotsToRoom(
    String roomId,
  ) async {
    return _remoteDataSource.inviteBotsToRoom(roomId);
  }

  @override
  Future<void> leaveRoom(String roomId) => _remoteDataSource.leaveRoom(roomId);

  @override
  Future<bool> sendStreamHeartbeat(String streamId) =>
      _remoteDataSource.sendStreamHeartbeat(streamId);

  @override
  Future<void> kickPlayer(String roomId, String targetUid) =>
      _remoteDataSource.kickPlayer(roomId, targetUid);

  @override
  Future<void> swapPlayerTeams(
    String roomId,
    String firstUid,
    String secondUid,
  ) => _remoteDataSource.swapPlayerTeams(roomId, firstUid, secondUid);

  @override
  Future<void> movePlayerToTeam(
    String roomId,
    String playerUid,
    String targetTeam,
  ) => _remoteDataSource.movePlayerToTeam(roomId, playerUid, targetTeam);

  @override
  Future<Room> startStream(String roomId) async {
    final model = await _remoteDataSource.startStream(roomId);
    return model.toEntity(currentUserUid: _currentUid);
  }

  @override
  Future<Room> endStream(String roomId) async {
    final model = await _remoteDataSource.endStream(roomId);
    return model.toEntity(currentUserUid: _currentUid);
  }

  @override
  Future<void> sendRoomInvite(String roomId, String friendUid) =>
      _remoteDataSource.sendRoomInvite(roomId, friendUid);
}
