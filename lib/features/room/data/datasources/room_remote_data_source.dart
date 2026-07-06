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
    return _firestore
        .collection('rooms')
        .where('type', isEqualTo: 'public')
        .where('status', isEqualTo: 'waiting')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => _mapDocToModel(doc.id, doc.data())).toList();
        })
        .handleError((Object error) {
          AppLogger.error('Failed to watch public rooms', error: error, tag: 'Room');
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
    const timeout = Duration(seconds: 10);
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const UnauthenticatedException();
    }

    // Get user profile from Firestore
    AppLogger.info('Fetching user profile for room creation...', tag: 'Room');
    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get()
        .timeout(timeout, onTimeout: () {
      throw const RoomException('Timed out reading user profile.');
    });
    final userData = userDoc.data();
    final displayName = userData?['displayName'] as String? ?? 'Player';
    final avatarUrl = userData?['avatarUrl'] as String?;
    final level = (userData?['level'] as num?)?.toInt() ?? 1;

    final inviteCode = _generateInviteCode();

    final roomRef = _firestore.collection('rooms').doc();
    final roomData = <String, dynamic>{
      'id': roomRef.id,
      'name': name,
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
          'agoraUid': user.uid.hashCode.abs(),
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
    await roomRef.set(roomData).timeout(
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

  Stream<List<RoomChatMessageModel>> watchChatMessages(String roomId) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('chat')
        .orderBy('createdAt', descending: false)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return RoomChatMessageModel(
              user: data['senderName'] as String? ?? 'Player',
              text: data['text'] as String? ?? '',
              isSystem: data['type'] == 'system',
            );
          }).toList();
        })
        .handleError((Object error) {
          AppLogger.error('Failed to watch chat', error: error, tag: 'Room');
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

  Future<void> sendChatMessage(String roomId, String message) async {
    final currentUid = _currentUid;
    if (currentUid.isEmpty) throw const UnauthenticatedException();

    // Get user name
    final userDoc = await _firestore.collection('users').doc(currentUid).get();
    final userData = userDoc.data();
    final displayName = userData?['displayName'] as String? ?? 'Player';

    await _firestore.collection('rooms').doc(roomId).collection('chat').add({
      'senderUid': currentUid,
      'senderName': displayName,
      'text': message,
      'type': 'text',
      'createdAt': FieldValue.serverTimestamp(),
    });
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
    });
  }

  Future<String> startGame(String roomId) async {
    final callable = _functions.httpsCallable('startGame');
    final result = await callable.call<Map<String, dynamic>>({'roomId': roomId});
    final data = result.data;
    return data['gameId'] as String;
  }

  /// Creates a real room with the current user plus 3 bot players, then starts
  /// the game. Returns both the room ID and the game ID.
  Future<({String roomId, String gameId})> createRoomWithBots() async {
    final callable = _functions.httpsCallable('createRoomWithBots');
    final result = await callable.call<Map<String, dynamic>>(<String, dynamic>{});
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
  Future<({String roomId, String? gameId})> inviteBotsToRoom(String roomId) async {
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

    final roomRef = _firestore.collection('rooms').doc(roomId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(roomRef);
      if (!doc.exists) throw const RoomNotFoundException();

      final data = doc.data()!;
      final players = List<Map<String, dynamic>>.from(data['players'] as List);
      final playerUids = List<String>.from(data['playerUids'] as List? ?? []);
      final readyPlayers = List<String>.from(data['readyPlayers'] as List? ?? []);
      final teamA = List<String>.from(data['teamA'] as List? ?? []);
      final teamB = List<String>.from(data['teamB'] as List? ?? []);

      final playerIndex = players.indexWhere((p) => p['uid'] == currentUid);
      if (playerIndex == -1) throw const PlayerNotInRoomException();

      players.removeAt(playerIndex);
      playerUids.remove(currentUid);
      readyPlayers.remove(currentUid);
      teamA.remove(currentUid);
      teamB.remove(currentUid);

      String? newCreatorUid;
      final oldCreatorUid = data['creatorUid'] as String?;
      if (oldCreatorUid == currentUid && playerUids.isNotEmpty) {
        newCreatorUid = playerUids.first;
      }

      // If game is active, mark player as disconnected in game doc
      final gameId = data['gameId'] as String?;
      if (gameId != null && data['status'] == 'playing') {
        final gameRef = _firestore.collection('games').doc(gameId);
        final gameDoc = await transaction.get(gameRef);
        if (gameDoc.exists) {
          final gameData = gameDoc.data()!;
          final gamePlayers = gameData['players'] as Map<String, dynamic>? ?? <String, dynamic>{};
          for (final entry in gamePlayers.entries) {
            final p = entry.value as Map<String, dynamic>;
            if (p['uid'] == currentUid) {
              p['isConnected'] = false;
              p['leftAt'] = FieldValue.serverTimestamp();
              break;
            }
          }
          transaction.update(gameRef, {'players': gamePlayers});
        }
      }

      if (playerUids.isEmpty) {
        transaction.delete(roomRef);
      } else {
        final updateData = <String, dynamic>{
          'players': players,
          'playerUids': playerUids,
          'readyPlayers': readyPlayers,
          'teamA': teamA,
          'teamB': teamB,
          'currentPlayerCount': players.length,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (newCreatorUid != null) {
          updateData['creatorUid'] = newCreatorUid;
        }
        transaction.update(roomRef, updateData);
      }
    });
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

    await _functions.httpsCallable('endStream').call<void>({
      'roomId': roomId,
    });

    // Return updated room
    return getRoomById(roomId);
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
      final readyPlayers = List<String>.from(data['readyPlayers'] as List? ?? []);
      final teamA = List<String>.from(data['teamA'] as List? ?? []);
      final teamB = List<String>.from(data['teamB'] as List? ?? []);
      final kickedPlayerUids = List<String>.from(data['kickedPlayerUids'] as List? ?? []);

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

    final query = await _firestore
        .collection('rooms')
        .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
        .where('status', isEqualTo: 'waiting')
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw const RoomNotFoundException();
    }

    final roomDoc = query.docs.first;
    final roomRef = roomDoc.reference;
    final roomType = roomDoc.data()['type'] as String? ?? 'private';
    final roomPassword = roomDoc.data()['password'] as String?;

    if (roomType == 'private' &&
        roomPassword != null &&
        roomPassword.isNotEmpty &&
        roomPassword != password) {
      throw const WrongPasswordException();
    }

    // Get user profile
    final userDoc = await _firestore.collection('users').doc(currentUid).get();
    final userData = userDoc.data();
    final displayName = userData?['displayName'] as String? ?? 'Player';
    final avatarUrl = userData?['avatarUrl'] as String?;

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(roomRef);
      if (!doc.exists) throw const RoomNotFoundException();

      final docData = doc.data()!;
      final players = List<Map<String, dynamic>>.from(
        docData['players'] as List,
      );
      final playerUids = List<String>.from(
        docData['playerUids'] as List? ?? [],
      );

      if (playerUids.contains(currentUid)) {
        throw const AlreadyInRoomException();
      }

      if (players.length >= 4) {
        throw const RoomFullException();
      }

      final teamA = List<String>.from(docData['teamA'] as List? ?? []);
      final teamB = List<String>.from(docData['teamB'] as List? ?? []);
      final team = teamA.length <= teamB.length ? 'A' : 'B';

      if (team == 'A') {
        teamA.add(currentUid);
      } else {
        teamB.add(currentUid);
      }

      players.add({
        'uid': currentUid,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'team': team,
        'seatIndex': players.length,
        'isReady': false,
        'isMicOn': docData['voiceEnabled'] == true,
        'isCameraOn': docData['cameraEnabled'] == true,
        'agoraUid': currentUid.hashCode.abs(),
        'joinedAt': DateTime.now(),
      });
      playerUids.add(currentUid);

      transaction.update(roomRef, {
        'players': players,
        'playerUids': playerUids,
        'teamA': teamA,
        'teamB': teamB,
        'currentPlayerCount': players.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    return getRoomById(roomDoc.id);
  }

  RoomModel _mapDocToModel(
    String id,
    Map<String, dynamic> data,
  ) {
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
