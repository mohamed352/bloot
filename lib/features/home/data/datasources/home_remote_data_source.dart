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
    return _firestore
        .collection('streams')
        .where('status', isEqualTo: 'live')
        .orderBy('viewerCount', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final streams = snapshot.docs.map((doc) {
            final data = doc.data();
            return _mapDocToEntity(doc.id, data);
          }).toList();
          return _filterActiveStreams(streams);
        })
        .handleError((Object error) {
          AppLogger.error(
            'Failed to watch live streams',
            error: error,
            tag: 'Home',
          );
          return <HomeStream>[];
        });
  }

  Future<List<HomeStream>> getLiveStreams() async {
    try {
      final snapshot = await _firestore
          .collection('streams')
          .where('status', isEqualTo: 'live')
          .orderBy('viewerCount', descending: true)
          .get();
      final streams = snapshot.docs.map((doc) {
        final data = doc.data();
        return _mapDocToEntity(doc.id, data);
      }).toList();
      return _filterActiveStreams(streams);
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
  /// cleared) so stale lives never appear.
  Future<List<HomeStream>> _filterActiveStreams(List<HomeStream> streams) async {
    if (streams.isEmpty) return streams;

    final roomIds = streams
        .map((s) => s.roomId)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toSet();

    if (roomIds.isEmpty) return [];

    final roomDocs = await Future.wait(
      roomIds.map((id) => _firestore.collection('rooms').doc(id).get()),
    );

    // Maps a valid room id to the stream id it currently broadcasts.
    final activeStreamByRoom = <String, String>{};
    for (final doc in roomDocs) {
      if (!doc.exists) continue;
      final data = doc.data()!;
      final playerUids = data['playerUids'];
      final status = data['status'] as String?;
      final hasPlayers = playerUids is List && playerUids.isNotEmpty;
      final isStreaming = data['isStreaming'] == true;
      final roomStreamId = data['streamId'] as String?;
      if (hasPlayers &&
          status == 'playing' &&
          isStreaming &&
          roomStreamId != null &&
          roomStreamId.isNotEmpty) {
        activeStreamByRoom[doc.id] = roomStreamId;
      }
    }

    return streams.where((s) {
      final roomId = s.roomId;
      return roomId != null &&
          roomId.isNotEmpty &&
          activeStreamByRoom[roomId] == s.id;
    }).toList();
  }
}
