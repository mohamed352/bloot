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

      return snapshot.docs.map((doc) => _mapStreamDoc(doc)).toList();
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
        return _mapStreamDoc(doc);
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

  DiscoverStreamModel _mapStreamDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
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

}
