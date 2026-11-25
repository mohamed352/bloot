import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/home/domain/entities/home_stream.dart';

@lazySingleton
class HomeRemoteDataSource {
  HomeRemoteDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<List<HomeStream>> watchLiveStreams() {
    late StreamController<List<HomeStream>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? snapshotSub;
    Timer? revalidationTimer;
    List<HomeStream> lastStreams = [];
    var filterPending = false;

    Future<void> refilter() async {
      if (filterPending) return;
      filterPending = true;
      try {
        final filtered = await _filterActiveStreams(lastStreams);
        if (!controller.isClosed) controller.add(filtered);
      } catch (e) {
        AppLogger.error('Failed to filter live streams', error: e, tag: 'Home');
      } finally {
        filterPending = false;
      }
    }

    controller = StreamController<List<HomeStream>>(
      onListen: () {
        snapshotSub = _firestore
            .collection('streams')
            .where('status', isEqualTo: 'live')
            .orderBy('viewerCount', descending: true)
            .limit(50)
            .snapshots()
            .listen(
              (snapshot) {
                lastStreams = snapshot.docs
                    .map((doc) => _mapDocToEntity(doc.id, doc.data()))
                    .toList();
                unawaited(refilter());
              },
              onError: (Object error) {
                AppLogger.error(
                  'Failed to watch live streams',
                  error: error,
                  tag: 'Home',
                );
                if (!controller.isClosed) controller.add(<HomeStream>[]);
              },
            );
        // Re-validate room state periodically: when a room finishes or is
        // deleted without a streams write in the same batch, its card would
        // otherwise linger until some unrelated stream write occurs.
        revalidationTimer = Timer.periodic(
          const Duration(minutes: 1),
          (_) => unawaited(refilter()),
        );
      },
      onCancel: () async {
        await snapshotSub?.cancel();
        revalidationTimer?.cancel();
        await controller.close();
      },
    );
    return controller.stream;
  }

  Future<List<HomeStream>> getLiveStreams() async {
    try {
      final snapshot = await _firestore
          .collection('streams')
          .where('status', isEqualTo: 'live')
          .orderBy('viewerCount', descending: true)
          .limit(50)
          .get();
      final streams = snapshot.docs.map((doc) {
        final data = doc.data();
        return _mapDocToEntity(doc.id, data);
      }).toList();
      return await _filterActiveStreams(streams);
    } catch (e) {
      AppLogger.error('Failed to get live streams', error: e, tag: 'Home');
      return [];
    }
  }

  HomeStream _mapDocToEntity(String id, Map<String, dynamic> data) {
    return HomeStream(
      id: id,
      title: data['title'] as String? ?? 'Untitled Stream',
      hostName: data['hostName'] as String? ?? 'Unknown',
      hostAvatar: data['hostAvatar'] as String? ?? '',
      viewerCount: (data['viewerCount'] as num?)?.toInt() ?? 0,
      type: data['type'] as String? ?? 'Baloot',
      thumbnailUrl: data['thumbnailUrl'] as String?,
      isPremium: data['isPremium'] == true,
      roomId: data['roomId'] as String?,
    );
  }

  /// Filters out streams that have no parent room, or whose parent room is
  /// missing, not currently playing, has no players, or no longer points at
  /// this stream (e.g. the host left and the room's isStreaming flag was
  /// cleared) so stale lives never appear. Rooms that disallow spectators
  /// stay listed (spectating itself is gated separately).
  Future<List<HomeStream>> _filterActiveStreams(
    List<HomeStream> streams,
  ) async {
    if (streams.isEmpty) return streams;

    final roomIds = streams
        .map((s) => s.roomId)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toSet();

    if (roomIds.isEmpty) return [];

    final roomsById = await _fetchRoomsById(roomIds);

    // Maps a valid room id to the stream id it currently broadcasts.
    final activeStreamByRoom = <String, String>{};
    for (final entry in roomsById.entries) {
      final data = entry.value;
      final playerUids = data['playerUids'];
      final status = data['status'] as String?;
      final hasPlayers = playerUids is List && playerUids.isNotEmpty;
      final isStreaming = data['isStreaming'] == true;
      final roomStreamId = data['streamId'] as String?;
      if (hasPlayers &&
          (status == 'playing' || status == 'waiting') &&
          isStreaming &&
          roomStreamId != null &&
          roomStreamId.isNotEmpty) {
        activeStreamByRoom[entry.key] = roomStreamId;
      }
    }

    return streams.where((s) {
      final roomId = s.roomId;
      return roomId != null &&
          roomId.isNotEmpty &&
          activeStreamByRoom[roomId] == s.id;
    }).toList();
  }

  /// Fetches room documents for [roomIds] with batched `whereIn` queries
  /// (30 ids per chunk, the Firestore limit) instead of one read per room.
  /// Returns a map of room id to its data; missing rooms are absent.
  Future<Map<String, Map<String, dynamic>>> _fetchRoomsById(
    Set<String> roomIds,
  ) async {
    final roomsById = <String, Map<String, dynamic>>{};
    final ids = roomIds.toList();
    const chunkSize = 30;
    for (var i = 0; i < ids.length; i += chunkSize) {
      final end = i + chunkSize > ids.length ? ids.length : i + chunkSize;
      final snapshot = await _firestore
          .collection('rooms')
          .where(FieldPath.documentId, whereIn: ids.sublist(i, end))
          .get();
      for (final doc in snapshot.docs) {
        roomsById[doc.id] = doc.data();
      }
    }
    return roomsById;
  }
}
