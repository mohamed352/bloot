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
  Future<Room> sendChatMessage(String roomId, String message) async {
    final model = await _remoteDataSource.sendChatMessage(roomId, message);
    return model.toEntity();
  }
}
