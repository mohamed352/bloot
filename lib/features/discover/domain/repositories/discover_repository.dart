import 'package:bloot/features/discover/domain/entities/discover_stream.dart';

/// Repository contract for discover operations.
abstract class DiscoverRepository {
  /// Returns the list of all streams.
  Future<List<DiscoverStream>> getStreams();

  /// Returns a real-time stream of live streams.
  Stream<List<DiscoverStream>> watchStreams();

  /// Returns the stream with the given [id].
  Future<DiscoverStream> getStreamById(String id);

  /// Returns a real-time stream of the stream document for [id].
  /// Allows watchers to receive live updates to player states and stream status.
  Stream<DiscoverStream> watchStream(String id);

  /// Returns a real-time stream of chat messages for [streamId].
  Stream<List<StreamChatMessage>> watchStreamChat(String streamId);

  /// Sends a chat [message] to [streamId].
  Future<void> sendChatMessage(String streamId, String message);

  /// Finds a live stream by its room invite [code].
  /// Returns the stream document id, or `null` when no live stream matches.
  Future<String?> findStreamIdByCode(String code);

  /// Increments the viewer count for [streamId].
  Future<void> incrementViewerCount(String streamId);

  /// Decrements the viewer count for [streamId].
  Future<void> decrementViewerCount(String streamId);

  /// Returns true if the room associated with [streamId] allows spectators.
  Future<bool> isSpectatorsAllowed(String streamId);

  /// Returns the active gameId for the room associated with [streamId],
  /// or null if the room has no active game.
  Future<String?> getRoomGameId(String streamId);

  /// Watches the room associated with [streamId] and emits the active gameId
  /// when the room status becomes 'playing'. Emits null when no game is active.
  Stream<String?> watchRoomGameId(String streamId);
}
