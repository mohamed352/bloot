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

  /// Finds a live stream by its room invite [code].
  ///
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

  /// Filters out streams whose parent room is missing, finished, or has no
  /// players so closed/empty rooms never appear as live.
  Future<List<DiscoverStreamModel>> _filterActiveStreams(
    List<DiscoverStreamModel> streams,
  ) async {
    if (streams.isEmpty) return streams;

    final roomIds = streams
        .map((s) => s.roomId)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toSet();

    if (roomIds.isEmpty) return streams;

    final roomDocs = await Future.wait(
      roomIds.map((id) => _firestore.collection('rooms').doc(id).get()),
    );

    final validRoomIds = <String>{};
    for (final doc in roomDocs) {
      if (!doc.exists) continue;
      final data = doc.data()!;
      final playerUids = data['playerUids'];
      final status = data['status'] as String?;
      final hasPlayers = playerUids is List && playerUids.isNotEmpty;
      if (hasPlayers && status != 'finished') {
        validRoomIds.add(doc.id);
      }
    }

    return streams.where((s) {
      final roomId = s.roomId;
      return roomId == null || roomId.isEmpty || validRoomIds.contains(roomId);
    }).toList();
  }
}
