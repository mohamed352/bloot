import 'package:bloot/features/home/domain/entities/home_stream.dart';

/// Repository contract for home screen data.
abstract class HomeRepository {
  /// Returns a real-time stream of live streams ordered by viewer count.
  Stream<List<HomeStream>> watchLiveStreams();

  /// Fetches live streams once (for refresh).
  Future<List<HomeStream>> getLiveStreams();
}
