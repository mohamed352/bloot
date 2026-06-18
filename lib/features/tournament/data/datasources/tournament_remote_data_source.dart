import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/tournament/data/models/tournament_model.dart';

@lazySingleton
class TournamentRemoteDataSource {
  TournamentRemoteDataSource({
    required FirebaseFirestore firestore,
    required firebase_auth.FirebaseAuth firebaseAuth,
  })  : _firestore = firestore,
        _firebaseAuth = firebaseAuth;

  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  String? get _uid => _firebaseAuth.currentUser?.uid;

  Future<List<TournamentModel>> getTournaments() async {
    try {
      final snapshot = await _firestore
          .collection('tournaments')
          .orderBy('startAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map(_mapDocToModel).toList();
    } catch (e) {
      AppLogger.error('Failed to fetch tournaments from Firestore', error: e);
      return [];
    }
  }

  Stream<TournamentModel> watchTournament(String id) {
    return _firestore
        .collection('tournaments')
        .doc(id)
        .snapshots()
        .map((doc) {
          if (!doc.exists) throw Exception('Tournament not found');
          return _mapDocToModel(doc);
        })
        .handleError((Object error) {
          AppLogger.error('Failed to watch tournament', error: error, tag: 'Tournament');
        });
  }

  Future<TournamentModel?> getTournamentById(String id) async {
    try {
      final doc = await _firestore.collection('tournaments').doc(id).get();
      if (doc.exists) {
        return _mapDocToModel(doc);
      }
    } catch (e) {
      AppLogger.error('Failed to fetch tournament from Firestore', error: e);
    }

    return null;
  }

  /// Adds the current user to the tournament's [participantIds].
  /// Returns the updated tournament model.
  Future<TournamentModel> joinTournament(String tournamentId) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');

    final docRef = _firestore.collection('tournaments').doc(tournamentId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception('Tournament not found');

      final data = snapshot.data()!;
      final participantIds =
          (data['participantIds'] as List<dynamic>? ?? [])
              .cast<String>();

      if (participantIds.contains(uid)) {
        throw Exception('Already joined this tournament');
      }

      final maxParticipants = _parseMaxParticipants(
        data['participants'] as String? ?? '',
      );
      if (maxParticipants > 0 && participantIds.length >= maxParticipants) {
        throw Exception('Tournament is full');
      }

      participantIds.add(uid);
      transaction.update(docRef, {
        'participantIds': participantIds,
        'participants': '${participantIds.length}/${maxParticipants > 0 ? maxParticipants : ''}',
      });
    });

    return _mapDocToModel(await docRef.get());
  }

  int _parseMaxParticipants(String participantsStr) {
    // Format: "23/64" → 64
    final parts = participantsStr.split('/');
    if (parts.length == 2) {
      return int.tryParse(parts[1]) ?? 0;
    }
    return 0;
  }

  TournamentModel _mapDocToModel(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final participantIds =
        (data['participantIds'] as List<dynamic>? ?? []).cast<String>();
    final uid = _uid;

    return TournamentModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      prize: data['prize'] as String? ?? '',
      participants: data['participants'] as String? ?? '',
      status: data['status'] as String? ?? '',
      date: data['date'] as String? ?? '',
      isPremium: data['isPremium'] == true,
      isJoined: uid != null && participantIds.contains(uid),
      entryFee: data['entryFee'] as String? ?? '',
      participantIds: participantIds,
      prizes: _mapPrizes(data['prizes']),
      bracket: _mapBracket(data['bracket'] ?? data['matches']),
      maxParticipants: (data['maxParticipants'] as num?)?.toInt() ?? 64,
      currentRound: (data['currentRound'] as num?)?.toInt() ?? 0,
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      endedAt: (data['endedAt'] as Timestamp?)?.toDate(),
      creatorUid: data['creatorUid'] as String?,
      format: data['format'] as String? ?? 'single_elimination',
    );
  }

  List<TournamentPrizeModel> _mapPrizes(dynamic raw) {
    if (raw is! List<dynamic>) return [];
    return raw.map((p) {
      final map = p as Map<String, dynamic>? ?? {};
      return TournamentPrizeModel(
        place: map['place'] as String? ?? '',
        amount: map['amount'] as String? ?? '',
      );
    }).toList();
  }

  List<TournamentMatchModel> _mapBracket(dynamic raw) {
    if (raw is! List<dynamic>) return [];
    return raw.map((m) {
      final map = m as Map<String, dynamic>? ?? {};
      return TournamentMatchModel(
        matchId: map['matchId'] as String? ?? '',
        playerAName: map['playerAName'] as String? ?? '',
        playerBName: map['playerBName'] as String? ?? '',
        playerAUid: map['playerAUid'] as String?,
        playerBUid: map['playerBUid'] as String?,
        winnerUid: map['winnerUid'] as String?,
        roomId: map['roomId'] as String?,
        gameId: map['gameId'] as String?,
        nextMatchId: map['nextMatchId'] as String?,
        roundIndex: (map['roundIndex'] as num?)?.toInt() ?? 0,
        matchIndex: (map['matchIndex'] as num?)?.toInt() ?? 0,
        playerAScore: map['playerAScore'] as int?,
        playerBScore: map['playerBScore'] as int?,
        status: map['status'] as String? ?? 'upcoming',
        isUserMatch: map['isUserMatch'] == true,
        playerAAvatarUrl: map['playerAAvatarUrl'] as String?,
        playerBAvatarUrl: map['playerBAvatarUrl'] as String?,
        teamAPlayerIds: (map['teamAPlayerIds'] as List<dynamic>? ?? []).cast<String>(),
        teamBPlayerIds: (map['teamBPlayerIds'] as List<dynamic>? ?? []).cast<String>(),
      );
    }).toList();
  }
}
