import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/room/data/models/room_model.dart';
import 'package:bloot/features/room/domain/exceptions/room_exception.dart';

@lazySingleton
class RoomRemoteDataSource {
  RoomRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
    required FirebaseFunctions functions,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth,
       _functions = functions;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFunctions _functions;

  String get _currentUid => _firebaseAuth.currentUser?.uid ?? '';

  Stream<List<RoomModel>> watchPublicRooms() {
    // NOTE: Intentionally no orderBy() here — a compound query with orderBy
    // needs a composite index, and when that index is missing Firestore
    // fails the whole listener (previously swallowed, showing a permanent
    // empty list). Two equality filters work with automatic single-field
    // indexes; we sort client-side by createdAt instead.
    return _firestore
        .collection('rooms')
        .where('type', isEqualTo: 'public')
        .where('status', isEqualTo: 'waiting')
        .limit(50)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.toList()
            ..sort((a, b) {
              final aTime = a.data()['createdAt'];
              final bTime = b.data()['createdAt'];
              final aMillis = aTime is Timestamp
                  ? aTime.millisecondsSinceEpoch
                  : 0;
              final bMillis = bTime is Timestamp
                  ? bTime.millisecondsSinceEpoch
                  : 0;
              return bMillis.compareTo(aMillis);
            });
          return docs.map((doc) => _mapDocToModel(doc.id, doc.data())).toList();
        });
  }

  Future<RoomModel> createRoom({
    required String name,
    required String type,
    required bool voiceEnabled,
    required bool cameraEnabled,
    required bool allowSpectators,
    required String gameSpeed,
    String? password,
  }) async {
    const timeout = Duration(seconds: 30);
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const UnauthenticatedException();
    }
    if (name.trim().isEmpty) {
      throw const RoomException('Room name is required.');
    }

    // Get user profile from Firestore
    AppLogger.info('Fetching user profile for room creation...', tag: 'Room');
    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get()
        .timeout(
          timeout,
          onTimeout: () {
            throw const RoomException('Timed out reading user profile.');
          },
        );
    final userData = userDoc.data();
    final displayName = userData?['displayName'] as String? ?? 'Player';
    final avatarUrl = userData?['avatarUrl'] as String?;
    final level = (userData?['level'] as num?)?.toInt() ?? 1;
    // Prefer the server-assigned Agora UID (matches what joinRoom assigns to
    // other players); the hash-based fallback must match AgoraService's
    // derivation for the same user.
    final agoraUid =
        (userData?['agoraUid'] as num?)?.toInt() ?? user.uid.hashCode.abs();

    final inviteCode = _generateInviteCode();

    final roomRef = _firestore.collection('rooms').doc();
    final roomData = <String, dynamic>{
      'id': roomRef.id,
      'name': name,
      // Lowercase copy for case-insensitive name search (works for Arabic
      // and mixed-case names, unlike per-case-variant prefix queries).
      'nameLower': name.trim().toLowerCase(),
      'type': type,
      'creatorUid': user.uid,
      'status': 'waiting',
      'voiceEnabled': voiceEnabled,
      'cameraEnabled': cameraEnabled,
      'allowSpectators': allowSpectators,
      'gameSpeed': gameSpeed,
      if (password != null && password.isNotEmpty) 'password': password,
      'inviteCode': inviteCode,
      'players': [
        {
          'uid': user.uid,
          'displayName': displayName,
          'avatarUrl': avatarUrl,
          'team': 'A',
          'seatIndex': 0,
          'isReady': false,
          'isMicOn': voiceEnabled,
          'isCameraOn': cameraEnabled,
          'agoraUid': agoraUid,
          'joinedAt': DateTime.now(),
        },
      ],
      'playerUids': [user.uid],
      'teamA': [user.uid],
      'teamB': <String>[],
      'readyPlayers': <String>[],
      'currentPlayerCount': 1,
      'maxPlayers': 4,
      'agoraChannelName': 'room_${roomRef.id}',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    AppLogger.info('Writing room document to Firestore...', tag: 'Room');
    await roomRef
        .set(roomData)
        .timeout(
          timeout,
          onTimeout: () => throw const RoomException(
            'Timed out creating room. Please check your connection and try again.',
          ),
        );
    AppLogger.info('Room created: ${roomRef.id}', tag: 'Room');

    // Write notification docs for invited players (deferred to direct-invite UI)
    // For now, no direct invites — share link is the primary invite mechanism.

    return RoomModel(
      id: roomRef.id,
      name: name,
      type: type,
      voiceEnabled: voiceEnabled,
      cameraEnabled: cameraEnabled,
      allowSpectators: allowSpectators,
      gameSpeed: gameSpeed,
      password: password,
      creatorUid: user.uid,
      inviteCode: inviteCode,
      players: [
        RoomPlayerModel(
          uid: user.uid,
          name: displayName,
          avatarUrl: avatarUrl,
          level: level,
          isMicOn: voiceEnabled,
          isCameraOn: cameraEnabled,
        ),
      ],
    );
  }

  Stream<RoomModel> watchRoom(String roomId) {
    final roomRef = _firestore.collection('rooms').doc(roomId);

    return roomRef
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            throw const RoomNotFoundException();
          }
          return _mapDocToModel(doc.id, doc.data()!);
        })
        .handleError((Object error) {
          AppLogger.error('Failed to watch room', error: error, tag: 'Room');
        });
  }

  Future<RoomModel> getRoomById(String id) async {
    final doc = await _firestore.collection('rooms').doc(id).get();
    if (!doc.exists) {
      throw const RoomNotFoundException();
    }
    return _mapDocToModel(doc.id, doc.data()!);
  }

  Future<RoomModel> toggleReady(String roomId) async {
    final currentUid = _currentUid;
    if (currentUid.isEmpty) throw const UnauthenticatedException();

    final roomRef = _firestore.collection('rooms').doc(roomId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(roomRef);
      if (!doc.exists) throw const RoomNotFoundException();

      final data = doc.data()!;
      final players = List<Map<String, dynamic>>.from(data['players'] as List);
      final readyPlayers = List<String>.from(
        data['readyPlayers'] as List? ?? [],
      );

      final playerIndex = players.indexWhere((p) => p['uid'] == currentUid);
      if (playerIndex == -1) throw const PlayerNotInRoomException();

      final isReady = players[playerIndex]['isReady'] == true;
      players[playerIndex]['isReady'] = !isReady;

      if (isReady) {
        readyPlayers.remove(currentUid);
      } else {
        readyPlayers.add(currentUid);
      }

      transaction.update(roomRef, {
        'players': players,
        'readyPlayers': readyPlayers,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    return getRoomById(roomId);
  }

  Future<void> updatePlayerMediaState(
    String roomId, {
    required bool isMicOn,
    required bool isCameraOn,
  }) async {
    final currentUid = _currentUid;
    if (currentUid.isEmpty) throw const UnauthenticatedException();

    final roomRef = _firestore.collection('rooms').doc(roomId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(roomRef);
      if (!doc.exists) throw const RoomNotFoundException();

      final data = doc.data()!;
      final players = List<Map<String, dynamic>>.from(data['players'] as List);

      final playerIndex = players.indexWhere((p) => p['uid'] == currentUid);
      if (playerIndex == -1) throw const PlayerNotInRoomException();

      players[playerIndex]['isMicOn'] = isMicOn;
      players[playerIndex]['isCameraOn'] = isCameraOn;

      transaction.update(roomRef, {
        'players': players,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Sync the stream document's players array if the room is streaming,
      // so watchers see live camera/mic state changes in real time.
      final streamId = data['streamId'] as String?;
      if (streamId != null && streamId.isNotEmpty) {
        final streamRef = _firestore.collection('streams').doc(streamId);
        final streamDoc = await transaction.get(streamRef);
        if (streamDoc.exists) {
          final streamData = streamDoc.data()!;
          final streamPlayers = List<Map<String, dynamic>>.from(
            streamData['players'] as List,
          );
          final streamPlayerIndex = streamPlayers.indexWhere(
            (p) => p['uid'] == currentUid,
          );
          if (streamPlayerIndex != -1) {
            streamPlayers[streamPlayerIndex]['isMicOn'] = isMicOn;
            streamPlayers[streamPlayerIndex]['isCameraOn'] = isCameraOn;
            transaction.update(streamRef, {'players': streamPlayers});
          }
        }
      }
    });
  }

  Future<String> startGame(String roomId) async {
    final callable = _functions.httpsCallable('startGame');
    final result = await callable.call<Map<String, dynamic>>({
      'roomId': roomId,
    });
    final data = result.data;
    return data['gameId'] as String;
  }

  /// Creates a real room with the current user plus 3 bot players, then starts
  /// the game. Returns both the room ID and the game ID.
  Future<({String roomId, String gameId})> createRoomWithBots() async {
    final callable = _functions.httpsCallable('createRoomWithBots');
    final result = await callable.call<Map<String, dynamic>>(
      <String, dynamic>{},
    );
    final data = result.data;
    final roomId = data['roomId'] as String?;
    final gameId = data['gameId'] as String?;
    if (roomId == null || gameId == null) {
      throw const RoomException('Failed to create bot room.');
    }
    return (roomId: roomId, gameId: gameId);
  }

  /// Invites bots to fill empty seats in an existing [roomId]. If the room
  /// becomes full, the game is started automatically and the game ID is
  /// returned.
  Future<({String roomId, String? gameId})> inviteBotsToRoom(
    String roomId,
  ) async {
    final callable = _functions.httpsCallable('inviteBotsToRoom');
    final result = await callable.call<Map<String, dynamic>>({
      'roomId': roomId,
    });
    final data = result.data;
    final returnedRoomId = data['roomId'] as String?;
    final gameId = data['gameId'] as String?;
    if (returnedRoomId == null) {
      throw const RoomException('Failed to invite bots.');
    }
    return (roomId: returnedRoomId, gameId: gameId);
  }

  Future<void> leaveRoom(String roomId) async {
    final currentUid = _currentUid;
    if (currentUid.isEmpty) throw const UnauthenticatedException();

    // Game documents are client-read-only, so use a callable function to update
    // both the room and the active game document atomically.
    final callable = _functions.httpsCallable('leaveGame');
    await callable.call<void>({'roomId': roomId});
  }

  /// Touches `streams/{streamId}.lastHeartbeatAt` so the server-side sweeper
  /// can detect a dead broadcast (host app killed/crashed without leaving)
  /// and end the stream instead of leaving it on the live list for ~30 min.
  Future<void> sendStreamHeartbeat(String streamId) async {
    try {
      await _firestore.collection('streams').doc(streamId).update({
        'lastHeartbeatAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Heartbeats are best-effort: a missed beat only means the sweeper
      // cleans up the stream a bit later.
      AppLogger.error('Failed to send stream heartbeat', error: e);
    }
  }

  Future<RoomModel> startStream(String roomId) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw const UnauthenticatedException();

    final result = await _functions
        .httpsCallable('startStream')
        .call<Map<String, dynamic>>({'roomId': roomId});

    final data = result.data;
    final streamId = data['streamId'] as String?;
    if (streamId == null || streamId.isEmpty) {
      throw Exception('startStream did not return a streamId');
    }

    // Return updated room
    return getRoomById(roomId);
  }

  Future<RoomModel> endStream(String roomId) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw const UnauthenticatedException();

    await _functions.httpsCallable('endStream').call<void>({'roomId': roomId});

    // Return updated room
    return getRoomById(roomId);
  }

  Future<void> sendRoomInvite(String roomId, String friendUid) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw const UnauthenticatedException();

    await _functions.httpsCallable('sendRoomInvite').call<void>({
      'roomId': roomId,
      'friendUid': friendUid,
    });
  }

  Future<void> kickPlayer(String roomId, String targetUid) async {
    final currentUid = _currentUid;
    if (currentUid.isEmpty) throw const UnauthenticatedException();

    final roomRef = _firestore.collection('rooms').doc(roomId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(roomRef);
      if (!doc.exists) throw const RoomNotFoundException();

      final data = doc.data()!;
      if (data['creatorUid'] != currentUid) {
        throw const RoomException('Only the host can kick players');
      }

      final players = List<Map<String, dynamic>>.from(data['players'] as List);
      final playerUids = List<String>.from(data['playerUids'] as List? ?? []);
      final readyPlayers = List<String>.from(
        data['readyPlayers'] as List? ?? [],
      );
      final teamA = List<String>.from(data['teamA'] as List? ?? []);
      final teamB = List<String>.from(data['teamB'] as List? ?? []);
      final kickedPlayerUids = List<String>.from(
        data['kickedPlayerUids'] as List? ?? [],
      );

      final playerIndex = players.indexWhere((p) => p['uid'] == targetUid);
      if (playerIndex == -1) throw const PlayerNotInRoomException();

      players.removeAt(playerIndex);
      playerUids.remove(targetUid);
      readyPlayers.remove(targetUid);
      teamA.remove(targetUid);
      teamB.remove(targetUid);
      kickedPlayerUids.add(targetUid);

      transaction.update(roomRef, {
        'players': players,
        'playerUids': playerUids,
        'readyPlayers': readyPlayers,
        'teamA': teamA,
        'teamB': teamB,
        'kickedPlayerUids': kickedPlayerUids,
        'currentPlayerCount': players.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Returns true if the waiting room with [inviteCode] is private and has a
  /// non-empty password.
  Future<bool> isPasswordRequired(String inviteCode) async {
    final query = await _firestore
        .collection('rooms')
        .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
        .where('status', isEqualTo: 'waiting')
        .limit(1)
        .get();

    if (query.docs.isEmpty) return false;

    final data = query.docs.first.data();
    final roomType = data['type'] as String? ?? 'private';
    final roomPassword = data['password'] as String?;
    return roomType == 'private' &&
        roomPassword != null &&
        roomPassword.isNotEmpty;
  }

  Future<RoomModel> joinRoomByCode(
    String inviteCode, {
    String? password,
  }) async {
    final currentUid = _currentUid;
    if (currentUid.isEmpty) throw const UnauthenticatedException();

    try {
      AppLogger.info(
        'Joining room via Cloud Function with invite code: ${inviteCode.toUpperCase()}',
        tag: 'RoomRemote',
      );

      final result = await _functions
          .httpsCallable('joinRoom')
          .call<Map<String, dynamic>>({
            'inviteCode': inviteCode,
            'password': password,
          })
          .timeout(const Duration(seconds: 15));

      final roomId = result.data['roomId'] as String?;
      if (roomId == null) {
        throw const RoomException('Failed to join room.');
      }

      AppLogger.info('Joined room: $roomId', tag: 'RoomRemote');
      return getRoomById(roomId);
    } on RoomException {
      rethrow;
    } on FirebaseFunctionsException catch (e) {
      AppLogger.error('joinRoom function error', error: e, tag: 'RoomRemote');
      switch (e.code) {
        case 'not-found':
          throw const RoomNotFoundException();
        case 'resource-exhausted':
          throw const RoomFullException();
        case 'permission-denied':
          final message = e.message ?? '';
          if (message.contains('removed from this room')) {
            throw RoomException(message);
          }
          throw const WrongPasswordException();
        case 'invalid-argument':
          if (e.message == 'Wrong password') {
            throw const WrongPasswordException();
          }
          throw RoomException(e.message ?? 'Failed to join room.');
        case 'unauthenticated':
          throw const UnauthenticatedException();
        default:
          throw RoomException(e.message ?? 'Failed to join room.');
      }
    } catch (e) {
      AppLogger.error('joinRoomByCode fallback error', error: e);
      throw const RoomException(
        'Failed to join room. Please check the code and try again.',
      );
    }
  }

  RoomModel _mapDocToModel(String id, Map<String, dynamic> data) {
    final currentUid = _currentUid;
    final players = (data['players'] as List? ?? []).map((p) {
      final map = p as Map<String, dynamic>;
      return RoomPlayerModel(
        uid: map['uid'] as String? ?? '',
        name: map['displayName'] as String? ?? 'Player',
        avatarUrl: map['avatarUrl'] as String?,
        isReady: map['isReady'] == true,
        isMe: map['uid'] == currentUid,
        team: map['team'] as String? ?? 'A',
        level: (map['level'] as num?)?.toInt(),
        isMicOn: map['isMicOn'] != false,
        isCameraOn: map['isCameraOn'] == true,
        agoraUid: (map['agoraUid'] as num?)?.toInt(),
        isSpeaking: map['isSpeaking'] == true,
      );
    }).toList();

    return RoomModel(
      id: id,
      name: data['name'] as String? ?? 'Room',
      type: data['type'] as String? ?? 'private',
      voiceEnabled: data['voiceEnabled'] != false,
      cameraEnabled: data['cameraEnabled'] == true,
      allowSpectators: data['allowSpectators'] != false,
      gameSpeed: data['gameSpeed'] as String? ?? 'normal',
      creatorUid: data['creatorUid'] as String?,
      inviteCode: data['inviteCode'] as String?,
      agoraChannelName: data['agoraChannelName'] as String?,
      players: players,
      status: data['status'] as String? ?? 'waiting',
      gameId: data['gameId'] as String?,
      isStreaming: data['isStreaming'] == true,
      streamId: data['streamId'] as String?,
    );
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
