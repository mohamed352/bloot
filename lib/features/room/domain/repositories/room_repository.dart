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

  /// Returns true if the waiting room with [inviteCode] is private and has a
  /// non-empty password.
  Future<bool> isPasswordRequired(String inviteCode);

  /// Joins a room by [inviteCode].
  /// [password] is required when the room is private and has a password.
  Future<Room> joinRoomByCode(String inviteCode, {String? password});

  /// Starts the game for [roomId]. Returns the created game ID.
  Future<String> startGame(String roomId);

  /// Creates a real room with the current user plus 3 bot players, then starts
  /// the game. Returns both the room ID and the game ID.
  Future<({String roomId, String gameId})> createRoomWithBots();

  /// Removes the current user from [roomId].
  Future<void> leaveRoom(String roomId);

  /// Removes [targetUid] from [roomId] (host only).
  Future<void> kickPlayer(String roomId, String targetUid);

  /// Starts streaming [roomId] to the discover page (host only).
  Future<Room> startStream(String roomId);

  /// Ends the stream for [roomId] (host only).
  Future<Room> endStream(String roomId);
}
