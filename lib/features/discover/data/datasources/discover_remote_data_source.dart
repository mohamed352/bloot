import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/discover/data/models/discover_stream_model.dart';

@lazySingleton
class DiscoverRemoteDataSource {
  DiscoverRemoteDataSource({
    required FirebaseFirestore firestore,
    required firebase_auth.FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  String? get _uid => _firebaseAuth.currentUser?.uid;

  Future<List<DiscoverStreamModel>> getStreams() async {
    try {
      final snapshot = await _firestore
          .collection('streams')
          .where('status', isEqualTo: 'live')
          .orderBy('viewerCount', descending: true)
          .get();

      final streams = snapshot.docs.map((doc) => _mapStreamDoc(doc)).toList();
      return _filterActiveStreams(streams);
    } catch (e) {
      AppLogger.error('Failed to get discover streams', error: e);
      return [];
    }
  }

  /// Returns a real-time stream of live streams so the discover page
  /// updates automatically when new streams go live or existing ones end.
  Stream<List<DiscoverStreamModel>> watchStreams() {
    return _firestore
        .collection('streams')
        .where('status', isEqualTo: 'live')
        .snapshots()
        .asyncMap((snapshot) async {
          final streams = snapshot.docs
              .map((doc) => _mapStreamDoc(doc))
              .toList();
          return _filterActiveStreams(streams);
        })
        .handleError((Object error) {
          AppLogger.error('Failed to watch discover streams', error: error);
        });
  }

  Future<DiscoverStreamModel> getStreamById(String id) => loadStream(id);

  Future<DiscoverStreamModel> loadStream(String id) async {
    try {
      final doc = await _firestore.collection('streams').doc(id).get();
      if (doc.exists) {
        final stream = _mapStreamDoc(doc);
        final activeStreams = await _filterActiveStreams([stream]);
        if (activeStreams.isEmpty) {
          throw Exception('Stream is no longer active: $id');
        }
        return stream;
      }
    } catch (e) {
      AppLogger.error('Failed to get stream by id: $id', error: e);
    }

    throw Exception('Stream not found: $id');
  }

  /// Returns a real-time stream of the stream document for [id].
  /// This allows watchers to receive live updates to player camera/mic
  /// states and stream status changes.
  Stream<DiscoverStreamModel> watchStream(String id) {
    return _firestore
        .collection('streams')
        .doc(id)
        .snapshots()
        .where((doc) => doc.exists)
        .map((doc) => _mapStreamDoc(doc))
        .handleError((Object error) {
          AppLogger.error('Failed to watch stream $id', error: error);
        });
  }

  Stream<List<StreamChatMessageModel>> watchStreamChat(String streamId) {
    final uid = _uid;

    return _firestore
        .collection('streams')
        .doc(streamId)
        .collection('chat')
        .orderBy('createdAt', descending: false)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => _mapChatDoc(doc, uid)).toList();
        })
        .handleError((Object error) {
          AppLogger.error(
            'Failed to watch stream chat for $streamId',
            error: error,
          );
        });
  }

  Future<void> sendChatMessage(String streamId, String message) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');

    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userData = userDoc.data() ?? {};

    await _firestore
        .collection('streams')
        .doc(streamId)
        .collection('chat')
        .add({
          'senderUid': uid,
          'senderName': userData['displayName'] as String? ?? 'Unknown',
          'senderAvatar': userData['avatarUrl'] as String?,
          'text': message,
          'type': 'text',
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  /// Increments the viewer count for [streamId] when a spectator joins.
  ///
  /// Spectators are tracked in a dedicated `spectatorCount` field; the
  /// backend recomputes `viewerCount = players + spectatorCount` whenever the
  /// roster changes, so the two never drift apart.
  Future<void> incrementViewerCount(String streamId) async {
    try {
      await _firestore.collection('streams').doc(streamId).update({
        'spectatorCount': FieldValue.increment(1),
        'viewerCount': FieldValue.increment(1),
      });
    } catch (e) {
      AppLogger.error('Failed to increment viewer count', error: e);
    }
  }

  /// Decrements the viewer count for [streamId] when a spectator leaves.
  Future<void> decrementViewerCount(String streamId) async {
    try {
      await _firestore.collection('streams').doc(streamId).update({
        'spectatorCount': FieldValue.increment(-1),
        'viewerCount': FieldValue.increment(-1),
      });
    } catch (e) {
      AppLogger.error('Failed to decrement viewer count', error: e);
    }
  }

  /// Returns true if the room associated with [streamId] allows spectators.
  /// Fails closed: any error (offline, missing docs) means "not allowed",
  /// otherwise spectators could bypass rooms that disabled them.
  Future<bool> isSpectatorsAllowed(String streamId) async {
    try {
      final streamDoc = await _firestore
          .collection('streams')
          .doc(streamId)
          .get();
      if (!streamDoc.exists) return false;
      final roomId = streamDoc.data()?['roomId'] as String?;
      if (roomId == null || roomId.isEmpty) return false;
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) return false;
      return roomDoc.data()?['allowSpectators'] == true;
    } catch (e) {
      AppLogger.error('Failed to check spectator access', error: e);
      return false;
    }
  }

  /// Returns the active gameId for the room associated with [streamId],
  /// or null if the room has no active game.
  Future<String?> getRoomGameId(String streamId) async {
    try {
      final streamDoc = await _firestore
          .collection('streams')
          .doc(streamId)
          .get();
      if (!streamDoc.exists) return null;
      final roomId = streamDoc.data()?['roomId'] as String?;
      if (roomId == null || roomId.isEmpty) return null;
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) return null;
      final status = roomDoc.data()?['status'] as String?;
      final gameId = roomDoc.data()?['gameId'] as String?;
      if (status == 'playing' && gameId != null && gameId.isNotEmpty) {
        return gameId;
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get room game id', error: e);
      return null;
    }
  }

  /// Watches the room associated with [streamId] and emits the active gameId
  /// when the room status becomes 'playing'. Emits null when no game is active.
  ///
  /// Listens to the room document itself (not the stream doc): starting a game
  /// only updates the room, and stream-doc listeners would never fire.
  Stream<String?> watchRoomGameId(String streamId) async* {
    DocumentSnapshot<Map<String, dynamic>> streamDoc;
    try {
      streamDoc = await _firestore.collection('streams').doc(streamId).get();
    } catch (e) {
      AppLogger.error('Failed to resolve stream room', error: e);
      yield null;
      return;
    }
    final roomId = streamDoc.data()?['roomId'] as String?;
    if (roomId == null || roomId.isEmpty) {
      yield null;
      return;
    }
    yield* _firestore
        .collection('rooms')
        .doc(roomId)
        .snapshots()
        .map((roomDoc) {
          if (!roomDoc.exists) return null;
          final status = roomDoc.data()?['status'] as String?;
          final gameId = roomDoc.data()?['gameId'] as String?;
          if (status == 'playing' && gameId != null && gameId.isNotEmpty) {
            return gameId;
          }
          return null;
        })
        .handleError((Object error) {
          AppLogger.error('Failed to watch room game id', error: error);
        });
  }

  /// Finds a live stream by its room invite [code].
  /// Codes live on `rooms.inviteCode`; stream docs reference their room via
  /// `roomId`, so we resolve the room first, then look up its live stream.
  /// Returns the stream document id, or `null` when nothing matches.
  Future<String?> findStreamIdByCode(String code) async {
    try {
      final normalized = code.trim().toUpperCase();
      if (normalized.isEmpty) return null;

      final roomSnapshot = await _firestore
          .collection('rooms')
          .where('inviteCode', isEqualTo: normalized)
          .limit(1)
          .get();
      if (roomSnapshot.docs.isEmpty) return null;

      final roomDoc = roomSnapshot.docs.first;
      final roomData = roomDoc.data();
      if (roomData['status'] == 'finished') return null;

      final streamSnapshot = await _firestore
          .collection('streams')
          .where('roomId', isEqualTo: roomDoc.id)
          .where('status', isEqualTo: 'live')
          .limit(1)
          .get();
      if (streamSnapshot.docs.isEmpty) return null;

      return streamSnapshot.docs.first.id;
    } catch (e) {
      AppLogger.error('Failed to find stream by code', error: e);
      return null;
    }
  }

  /// Finds a live stream by room name (case-insensitive prefix match on the
  /// `nameLower` field, falling back to the legacy per-case-variant prefix
  /// queries for rooms created before `nameLower` existed).
  /// Returns the stream document id, or `null` when no live stream matches.
  Future<String?> findStreamIdByRoomName(String name) async {
    try {
      final trimmed = name.trim();
      if (trimmed.isEmpty) return null;

      final seenRoomIds = <String>{};

      Future<String?> findLiveStreamFor(
        List<QueryDocumentSnapshot<Map<String, dynamic>>> roomDocs,
      ) async {
        for (final roomDoc in roomDocs) {
          if (!seenRoomIds.add(roomDoc.id)) continue;
          final roomData = roomDoc.data();
          if (roomData['status'] == 'finished') continue;

          final streamSnapshot = await _firestore
              .collection('streams')
              .where('roomId', isEqualTo: roomDoc.id)
              .where('status', isEqualTo: 'live')
              .limit(1)
              .get();
          if (streamSnapshot.docs.isNotEmpty) {
            return streamSnapshot.docs.first.id;
          }
        }
        return null;
      }

      // Primary: case-insensitive prefix on nameLower (Arabic/mixed-case safe).
      final lower = trimmed.toLowerCase();
      try {
        final lowerSnapshot = await _firestore
            .collection('rooms')
            .where('nameLower', isGreaterThanOrEqualTo: lower)
            .where('nameLower', isLessThan: '$lower\uf8ff')
            .limit(5)
            .get();
        final found = await findLiveStreamFor(lowerSnapshot.docs);
        if (found != null) return found;
      } catch (e) {
        // nameLower may not be indexed yet on older data — fall through.
        AppLogger.error('nameLower search failed', error: e);
      }

      // Fallback for rooms created before nameLower existed: legacy
      // per-case-variant prefix queries on the raw name field.
      final upper = trimmed[0].toUpperCase() + trimmed.substring(1);
      for (final variant in [trimmed, lower, upper]) {
        final roomSnapshot = await _firestore
            .collection('rooms')
            .where('name', isGreaterThanOrEqualTo: variant)
            .where('name', isLessThan: '$variant\uf8ff')
            .limit(5)
            .get();
        final found = await findLiveStreamFor(roomSnapshot.docs);
        if (found != null) return found;
      }

      return null;
    } catch (e) {
      AppLogger.error('Failed to find stream by room name', error: e);
      return null;
    }
  }

  DiscoverStreamModel _mapStreamDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return DiscoverStreamModel(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled Stream',
      host: data['hostName'] as String? ?? 'Unknown',
      viewers: (data['viewerCount'] as num?)?.toInt() ?? 0,
      avatarUrl: data['hostAvatar'] as String? ?? '',
      category: data['type'] as String? ?? 'Baloot',
      isLive: (data['status'] as String?) == 'live',
      isPremium: data['isPremium'] == true,
      agoraChannelName: data['agoraChannelName'] as String?,
      roomId: data['roomId'] as String?,
      players: _mapPlayers(data['players']),
    );
  }

  List<StreamPlayerModel> _mapPlayers(dynamic raw) {
    if (raw is! List<dynamic>) return [];
    return raw.map((p) {
      final map = p as Map<String, dynamic>? ?? {};
      return StreamPlayerModel(
        uid: map['uid'] as String? ?? '',
        name: map['name'] as String? ?? 'Player',
        avatarUrl: map['avatarUrl'] as String?,
        agoraUid: (map['agoraUid'] as num?)?.toInt() ?? 0,
        team: map['team'] as String? ?? 'A',
        isCameraOn: map['isCameraOn'] == true,
        isMicOn: map['isMicOn'] != false,
      );
    }).toList();
  }

  StreamChatMessageModel _mapChatDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String? currentUid,
  ) {
    final data = doc.data()!;
    final createdAt = data['createdAt'];

    return StreamChatMessageModel(
      id: doc.id,
      senderUid: data['senderUid'] as String? ?? '',
      senderName: data['senderName'] as String? ?? 'Unknown',
      senderAvatar: data['senderAvatar'] as String?,
      text: data['text'] as String? ?? '',
      type: data['type'] as String? ?? 'text',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      isMe: (data['senderUid'] as String?) == currentUid,
    );
  }

  /// Filters out streams that have no parent room, or whose parent room is
  /// missing, not currently playing, has no players, or no longer points at
  /// this stream (e.g. the host left and the room's isStreaming flag was
  /// cleared) so stale lives never appear.
  Future<List<DiscoverStreamModel>> _filterActiveStreams(
    List<DiscoverStreamModel> streams,
  ) async {
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
          (status == 'playing' || status == 'waiting') &&
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
