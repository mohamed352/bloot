import 'package:bloot/features/discover/domain/entities/discover_stream.dart';

/// Repository contract for discover operations.
abstract class DiscoverRepository {
  /// Returns the list of all streams.
  Future<List<DiscoverStream>> getStreams();

  /// Returns the stream with the given [id].
  Future<DiscoverStream> getStreamById(String id);

  /// Returns a real-time stream of chat messages for [streamId].
  Stream<List<StreamChatMessage>> watchStreamChat(String streamId);

  /// Sends a chat [message] to [streamId].
  Future<void> sendChatMessage(
    String streamId,
    String message,
  );
}
