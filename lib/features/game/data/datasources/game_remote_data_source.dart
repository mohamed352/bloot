import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/game/data/models/game_model.dart';

@lazySingleton
class GameRemoteDataSource {
  GameRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
    required FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _functions = functions,
       _firebaseAuth = firebaseAuth;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final FirebaseAuth _firebaseAuth;

  String get _currentUid => _firebaseAuth.currentUser?.uid ?? '';

  /// Returns a one-time fetch of a game (useful for initial load).
  Future<GameModel> getGameById(String id) async {
    final doc = await _firestore.collection('games').doc(id).get();
    if (!doc.exists) throw Exception('Game not found');
    return _mapDocToModel(doc);
  }

  /// Returns a real-time stream of the game document.
  Stream<GameModel> watchGame(String id) {
    return _firestore.collection('games').doc(id).snapshots().map((snapshot) {
      if (!snapshot.exists) throw Exception('Game not found');
      return _mapDocToModel(snapshot);
    });
  }

  /// Returns a spectator view of the game (hands hidden).
  Stream<GameModel> watchGameAsSpectator(String id) {
    return watchGame(id).map((game) {
      return game.copyWith(
        players: game.players.map((p) => p.copyWith(hand: [])).toList(),
        myHand: [],
      );
    });
  }

  /// Calls the Cloud Function to place a bid.
  Future<void> placeBid(String gameId, String bid) async {
    final callable = _functions.httpsCallable('placeBid');
    await callable.call<Map<String, dynamic>>({'gameId': gameId, 'bid': bid});
  }

  /// Calls the Cloud Function to play a card.
  Future<void> playCard(String gameId, String card) async {
    final callable = _functions.httpsCallable('playCard');
    await callable.call<Map<String, dynamic>>({'gameId': gameId, 'card': card});
  }

  /// Calls the Cloud Function to claim bonuses (Hokm only).
  Future<void> claimBonuses(
    String gameId,
    List<Map<String, dynamic>> bonuses,
  ) async {
    final callable = _functions.httpsCallable('claimBonuses');
    await callable.call<Map<String, dynamic>>({
      'gameId': gameId,
      'bonuses': bonuses,
    });
  }

  /// Calls the Cloud Function to deal the next round.
  Future<void> dealNextRound(String gameId) async {
    final callable = _functions.httpsCallable('dealNextRound');
    await callable.call<Map<String, dynamic>>({'gameId': gameId});
  }

  /// Calls the Cloud Function to rematch (reset room to waiting).
  Future<void> rematch(String roomId) async {
    final callable = _functions.httpsCallable('rematch');
    await callable.call<Map<String, dynamic>>({'roomId': roomId});
  }

  Future<void> declareProject(String gameId, List<String> types) async {
    final callable = _functions.httpsCallable('declareProject');
    await callable.call<Map<String, dynamic>>({
      'gameId': gameId,
      'types': types,
    });
  }

  Future<void> applyDouble(String gameId, String action) async {
    final callable = _functions.httpsCallable('applyDouble');
    await callable.call<Map<String, dynamic>>({
      'gameId': gameId,
      'action': action,
    });
  }

  Future<void> claimQaid(String gameId, String? claimType) async {
    final callable = _functions.httpsCallable('claimQaid');
    await callable.call<Map<String, dynamic>>({
      'gameId': gameId,
      'claimType': claimType,
    });
  }

  Future<void> claimSawa(String gameId) async {
    final callable = _functions.httpsCallable('claimSawa');
    await callable.call<Map<String, dynamic>>({'gameId': gameId});
  }

  /// Creates a custom Firebase token so the WebView can authenticate its own
  /// Firebase JS SDK and read the RTDB game mirror with the same UID.
  Future<String?> createRtdbToken() async {
    try {
      final callable = _functions.httpsCallable('createRtdbToken');
      final result = await callable.call<Map<String, dynamic>>();
      return result.data['token'] as String?;
    } catch (e) {
      AppLogger.error('Failed to create RTDB token', error: e);
      return null;
    }
  }

  GameModel _mapDocToModel(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) throw Exception('Game data is null');

    final playersMap = data['players'] as Map<String, dynamic>? ?? {};

    final players = playersMap.entries.map((entry) {
      final p = entry.value as Map<String, dynamic>? ?? {};
      final seatIndex = int.tryParse(entry.key) ?? 0;
      return GamePlayerModel(
        uid: p['uid'] as String? ?? '',
        name: p['displayName'] as String? ?? '',
        avatarUrl: p['avatarUrl'] as String? ?? '',
        team: p['team'] as String? ?? 'A',
        seatIndex: seatIndex,
        hand: (p['hand'] as List<dynamic>?)?.cast<String>() ?? [],
        takenCards: (p['takenCards'] as List<dynamic>?)?.cast<String>() ?? [],
        tricksWon: p['tricksWon'] as int? ?? 0,
        bid: p['bid'] as String?,
        isConnected: p['isConnected'] as bool? ?? true,
        isMuted: p['isMuted'] as bool? ?? false,
        hasCamera: p['hasCamera'] as bool? ?? true,
        agoraUid: (p['agoraUid'] as num?)?.toInt(),
      );
    }).toList();

    // Sort by seat index
    players.sort((a, b) => a.seatIndex.compareTo(b.seatIndex));

    if (players.isEmpty) {
      throw Exception('Game has no players');
    }

    // Determine current user's seat
    final mySeat = players
        .firstWhere((p) => p.uid == _currentUid, orElse: () => players.first)
        .seatIndex;

    final trickData = data['currentTrick'] as Map<String, dynamic>?;
    final trick = trickData != null
        ? TrickModel(
            trickNumber: trickData['trickNumber'] as int? ?? 1,
            trickLeaderIndex: trickData['trickLeaderIndex'] as int? ?? 0,
            leadingSuit: trickData['leadingSuit'] as String?,
            cards:
                (trickData['cards'] as Map<String, dynamic>?)?.map(
                  (k, v) => MapEntry(k, v as String?),
                ) ??
                {},
          )
        : null;

    final teamAScore = data['teamAScore'] as int? ?? 0;
    final teamBScore = data['teamBScore'] as int? ?? 0;
    final localTeam = players
        .firstWhere((p) => p.seatIndex == mySeat, orElse: () => players.first)
        .team;
    final isTeamA = localTeam == 'A';

    final playedCards = trick != null
        ? [
            trick.cards['0'],
            trick.cards['1'],
            trick.cards['2'],
            trick.cards['3'],
          ]
        : <String?>[];

    return GameModel(
      id: doc.id,
      players: players,
      myHand: players
          .firstWhere((p) => p.seatIndex == mySeat, orElse: () => players.first)
          .hand,
      mySeatIndex: mySeat,
      playedCards: playedCards,
      scoreUs: isTeamA ? teamAScore : teamBScore,
      scoreThem: isTeamA ? teamBScore : teamAScore,
      teamAScore: teamAScore,
      teamBScore: teamBScore,
      trump: data['trumpSuit'] as String? ?? '',
      status: data['status'] as String? ?? 'dealing',
      turnIndex: data['turnIndex'] as int? ?? 0,
      currentRound: data['currentRound'] as int? ?? 1,
      targetScore: data['targetScore'] as int? ?? 152,
      gameType: data['gameType'] as String?,
      dealerIndex: data['dealerIndex'] as int? ?? 0,
      faceUpCard: data['faceUpCard'] as String?,
      biddingTeam: data['biddingTeam'] as String?,
      fellTeam: data['fellTeam'] as String?,
      currentTrick: trick,
      roomId: data['roomId'] as String?,
      agoraChannelName: data['agoraChannelName'] as String?,
      engineState: data['engineState'] as Map<String, dynamic>?,
    );
  }
}
