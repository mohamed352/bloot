export 'package:bloot/features/room/domain/entities/create_room_params.dart';
import 'package:bloot/features/room/domain/entities/create_room_params.dart';
import 'package:bloot/features/room/domain/entities/room.dart';

/// Repository contract for room operations.
abstract class RoomRepository {
  /// Creates a new room with the given [params].
  Future<Room> createRoom(CreateRoomParams params);

  /// Returns a real-time stream of the room with the given [id].
  Stream<Room> watchRoom(String id);

  /// Watches public rooms that are waiting for players.
  Stream<List<Room>> watchPublicRooms();

  /// Returns the room with the given [id] (one-time fetch).
  Future<Room> getRoomById(String id);

  /// Toggles the ready status for the current user in [roomId].
  Future<Room> toggleReady(String roomId);

  /// Sends a chat [message] to [roomId].
  Future<void> sendChatMessage(String roomId, String message);

  /// Returns a real-time stream of chat messages for [roomId].
  Stream<List<RoomChatMessage>> watchChatMessages(String roomId);

  /// Updates the current player's mic and camera state in [roomId].
  Future<void> updatePlayerMediaState(
    String roomId, {
    required bool isMicOn,
    required bool isCameraOn,
  });

  /// Joins a room by [inviteCode].
  Future<Room> joinRoomByCode(String inviteCode);

  /// Starts the game for [roomId]. Returns the created game ID.
  Future<String> startGame(String roomId);

  /// Removes the current user from [roomId].
  Future<void> leaveRoom(String roomId);

  /// Removes [targetUid] from [roomId] (host only).
  Future<void> kickPlayer(String roomId, String targetUid);

  /// Starts streaming [roomId] to the discover page (host only).
  Future<Room> startStream(String roomId);

  /// Ends the stream for [roomId] (host only).
  Future<Room> endStream(String roomId);
}
