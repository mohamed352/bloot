import 'dart:async';

import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';

/// App-level host stream heartbeat.
///
/// Lives outside any cubit so the heartbeat keeps running while the host
/// navigates between the room lobby (RoomCubit) and the game page
/// (GameCubit). Previously the timer was owned by the lobby's RoomCubit and
/// died as soon as the host entered the game screen, which let the server
/// sweeper kill healthy live streams mid-game.
///
/// The beat self-terminates when the stream doc is gone or no longer `live`
/// so a zombie timer can never keep a dead broadcast on the live list.
@lazySingleton
class StreamHeartbeatService {
  StreamHeartbeatService({required RoomRepository roomRepository})
    : _roomRepository = roomRepository;

  final RoomRepository _roomRepository;

  Timer? _timer;
  String? _streamId;

  /// The stream currently being kept alive, if any.
  String? get activeStreamId => _streamId;

  /// Starts (or keeps) the heartbeat for [streamId]. Idempotent: calling it
  /// repeatedly for the same stream is a no-op.
  void start(String streamId) {
    if (streamId.isEmpty) return;
    if (_streamId == streamId && _timer != null) return;
    stop();
    _streamId = streamId;
    // First beat immediately, then once a minute. Best-effort: failures are
    // swallowed so a heartbeat can never crash the session.
    unawaited(_beat(streamId));
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      unawaited(_beat(streamId));
    });
  }

  /// Stops the heartbeat. If [streamId] is given, only stops when it matches
  /// the active one.
  void stop([String? streamId]) {
    if (streamId != null && streamId != _streamId) return;
    _timer?.cancel();
    _timer = null;
    _streamId = null;
  }

  Future<void> _beat(String streamId) async {
    try {
      final alive = await _roomRepository.sendStreamHeartbeat(streamId);
      if (!alive) {
        // Stream ended or was deleted server-side — stop beating so the
        // sweeper can clean up.
        stop(streamId);
      }
    } catch (e) {
      AppLogger.error('Stream heartbeat failed', error: e);
    }
  }

  @disposeMethod
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _streamId = null;
  }
}
