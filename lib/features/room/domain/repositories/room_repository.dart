import 'package:bloot/features/room/domain/entities/room.dart';

/// Repository contract for room operations.
abstract class RoomRepository {
  /// Creates a new room with the given [params].
  Future<Room> createRoom(CreateRoomParams params);

  /// Returns the room with the given [id].
  Future<Room> getRoomById(String id);

  /// Toggles the ready status for the current user in [roomId].
  Future<Room> toggleReady(String roomId);

  /// Sends a chat [message] to [roomId].
  Future<Room> sendChatMessage(String roomId, String message);
}

class CreateRoomParams {
  const CreateRoomParams({
    required this.name,
    required this.type,
    this.voiceEnabled = true,
    this.cameraEnabled = false,
    this.allowSpectators = true,
    this.gameSpeed = GameSpeed.normal,
  });

  final String name;
  final RoomType type;
  final bool voiceEnabled;
  final bool cameraEnabled;
  final bool allowSpectators;
  final GameSpeed gameSpeed;
}
