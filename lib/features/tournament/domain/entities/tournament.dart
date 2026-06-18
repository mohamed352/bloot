/// Domain entity representing a tournament prize.
class TournamentPrize {
  const TournamentPrize({required this.place, required this.amount});

  final String place;
  final String amount;
}

/// Domain entity representing a single bracket match.
class TournamentMatch {
  const TournamentMatch({
    required this.matchId,
    required this.playerAName,
    required this.playerBName,
    this.playerAUid,
    this.playerBUid,
    this.winnerUid,
    this.roomId,
    this.gameId,
    this.nextMatchId,
    this.roundIndex = 0,
    this.matchIndex = 0,
    this.playerAScore,
    this.playerBScore,
    required this.status,
    this.isUserMatch = false,
    this.playerAAvatarUrl,
    this.playerBAvatarUrl,
    this.teamAPlayerIds = const [],
    this.teamBPlayerIds = const [],
  });

  final String matchId;
  final String playerAName;
  final String playerBName;
  final String? playerAUid;
  final String? playerBUid;
  final String? winnerUid;
  final String? roomId;
  final String? gameId;
  final String? nextMatchId;
  final int roundIndex;
  final int matchIndex;
  final int? playerAScore;
  final int? playerBScore;
  final String status;
  final bool isUserMatch;
  final String? playerAAvatarUrl;
  final String? playerBAvatarUrl;
  final List<String> teamAPlayerIds;
  final List<String> teamBPlayerIds;

  TournamentMatch copyWith({
    String? matchId,
    String? playerAName,
    String? playerBName,
    String? playerAUid,
    String? playerBUid,
    String? winnerUid,
    String? roomId,
    String? gameId,
    String? nextMatchId,
    int? roundIndex,
    int? matchIndex,
    int? playerAScore,
    int? playerBScore,
    String? status,
    bool? isUserMatch,
    String? playerAAvatarUrl,
    String? playerBAvatarUrl,
    List<String>? teamAPlayerIds,
    List<String>? teamBPlayerIds,
  }) {
    return TournamentMatch(
      matchId: matchId ?? this.matchId,
      playerAName: playerAName ?? this.playerAName,
      playerBName: playerBName ?? this.playerBName,
      playerAUid: playerAUid ?? this.playerAUid,
      playerBUid: playerBUid ?? this.playerBUid,
      winnerUid: winnerUid ?? this.winnerUid,
      roomId: roomId ?? this.roomId,
      gameId: gameId ?? this.gameId,
      nextMatchId: nextMatchId ?? this.nextMatchId,
      roundIndex: roundIndex ?? this.roundIndex,
      matchIndex: matchIndex ?? this.matchIndex,
      playerAScore: playerAScore ?? this.playerAScore,
      playerBScore: playerBScore ?? this.playerBScore,
      status: status ?? this.status,
      isUserMatch: isUserMatch ?? this.isUserMatch,
      playerAAvatarUrl: playerAAvatarUrl ?? this.playerAAvatarUrl,
      playerBAvatarUrl: playerBAvatarUrl ?? this.playerBAvatarUrl,
      teamAPlayerIds: teamAPlayerIds ?? this.teamAPlayerIds,
      teamBPlayerIds: teamBPlayerIds ?? this.teamBPlayerIds,
    );
  }
}

/// Domain entity representing a tournament.
class Tournament {
  const Tournament({
    required this.id,
    required this.name,
    required this.prize,
    required this.participants,
    required this.status,
    required this.date,
    this.isPremium = false,
    this.isJoined = false,
    this.prizes = const [],
    this.bracket = const [],
    this.entryFee = '',
    this.participantIds = const [],
    this.maxParticipants = 64,
    this.currentRound = 0,
    this.startedAt,
    this.endedAt,
    this.creatorUid,
    this.format = 'single_elimination',
  });

  final String id;
  final String name;
  final String prize;
  final String participants;
  final String status;
  final String date;
  final bool isPremium;
  final bool isJoined;
  final List<TournamentPrize> prizes;
  final List<TournamentMatch> bracket;
  final String entryFee;
  final List<String> participantIds;
  final int maxParticipants;
  final int currentRound;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? creatorUid;
  final String format;

  Tournament copyWith({
    String? id,
    String? name,
    String? prize,
    String? participants,
    String? status,
    String? date,
    bool? isPremium,
    bool? isJoined,
    List<TournamentPrize>? prizes,
    List<TournamentMatch>? bracket,
    String? entryFee,
    List<String>? participantIds,
    int? maxParticipants,
    int? currentRound,
    DateTime? startedAt,
    DateTime? endedAt,
    String? creatorUid,
    String? format,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      prize: prize ?? this.prize,
      participants: participants ?? this.participants,
      status: status ?? this.status,
      date: date ?? this.date,
      isPremium: isPremium ?? this.isPremium,
      isJoined: isJoined ?? this.isJoined,
      prizes: prizes ?? this.prizes,
      bracket: bracket ?? this.bracket,
      entryFee: entryFee ?? this.entryFee,
      participantIds: participantIds ?? this.participantIds,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentRound: currentRound ?? this.currentRound,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      creatorUid: creatorUid ?? this.creatorUid,
      format: format ?? this.format,
    );
  }
}
