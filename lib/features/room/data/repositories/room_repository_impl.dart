import 'package:injectable/injectable.dart';

import 'package:bloot/features/room/data/datasources/room_remote_data_source.dart';
import 'package:bloot/features/room/data/models/room_model.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';

@LazySingleton(as: RoomRepository)
class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl({required RoomRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final RoomRemoteDataSource _remoteDataSource;

  @override
  Future<Room> createRoom(CreateRoomParams params) async {
    final model = await _remoteDataSource.createRoom(
      name: params.name,
      type: params.type.name,
      voiceEnabled: params.voiceEnabled,
      cameraEnabled: params.cameraEnabled,
      allowSpectators: params.allowSpectators,
      gameSpeed: params.gameSpeed.name,
    );
    return model.toEntity();
  }

  @override
  Stream<Room> watchRoom(String id) {
    return _remoteDataSource.watchRoom(id).map((model) => model.toEntity());
  }

  @override
  Stream<List<Room>> watchPublicRooms() {
    return _remoteDataSource.watchPublicRooms().map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Future<Room> getRoomById(String id) async {
    final model = await _remoteDataSource.getRoomById(id);
    return model.toEntity();
  }

  @override
  Future<Room> toggleReady(String roomId) async {
    final model = await _remoteDataSource.toggleReady(roomId);
    return model.toEntity();
  }

  @override
  Future<void> sendChatMessage(String roomId, String message) async {
    await _remoteDataSource.sendChatMessage(roomId, message);
  }

  @override
  Stream<List<RoomChatMessage>> watchChatMessages(String roomId) {
    return _remoteDataSource
        .watchChatMessages(roomId)
        .map((models) => models.map((m) => m.toEntity()).toList());
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
  Future<Room> joinRoomByCode(String inviteCode) async {
    final model = await _remoteDataSource.joinRoomByCode(inviteCode);
    return model.toEntity();
  }

  @override
  Future<String> startGame(String roomId) async {
    return _remoteDataSource.startGame(roomId);
  }

  @override
  Future<void> leaveRoom(String roomId) => _remoteDataSource.leaveRoom(roomId);

  @override
  Future<void> kickPlayer(String roomId, String targetUid) =>
      _remoteDataSource.kickPlayer(roomId, targetUid);

  @override
  Future<Room> startStream(String roomId) async {
    final model = await _remoteDataSource.startStream(roomId);
    return model.toEntity();
  }

  @override
  Future<Room> endStream(String roomId) async {
    final model = await _remoteDataSource.endStream(roomId);
    return model.toEntity();
  }
}
