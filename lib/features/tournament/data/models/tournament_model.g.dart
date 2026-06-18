// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TournamentPrizeModel _$TournamentPrizeModelFromJson(
  Map<String, dynamic> json,
) => _TournamentPrizeModel(
  place: json['place'] as String,
  amount: json['amount'] as String,
);

Map<String, dynamic> _$TournamentPrizeModelToJson(
  _TournamentPrizeModel instance,
) => <String, dynamic>{'place': instance.place, 'amount': instance.amount};

_TournamentMatchModel _$TournamentMatchModelFromJson(
  Map<String, dynamic> json,
) => _TournamentMatchModel(
  matchId: json['matchId'] as String,
  playerAName: json['playerAName'] as String,
  playerBName: json['playerBName'] as String,
  playerAUid: json['playerAUid'] as String?,
  playerBUid: json['playerBUid'] as String?,
  winnerUid: json['winnerUid'] as String?,
  roomId: json['roomId'] as String?,
  gameId: json['gameId'] as String?,
  nextMatchId: json['nextMatchId'] as String?,
  roundIndex: (json['roundIndex'] as num?)?.toInt() ?? 0,
  matchIndex: (json['matchIndex'] as num?)?.toInt() ?? 0,
  playerAScore: (json['playerAScore'] as num?)?.toInt(),
  playerBScore: (json['playerBScore'] as num?)?.toInt(),
  status: json['status'] as String? ?? 'upcoming',
  isUserMatch: json['isUserMatch'] as bool? ?? false,
  playerAAvatarUrl: json['playerAAvatarUrl'] as String?,
  playerBAvatarUrl: json['playerBAvatarUrl'] as String?,
  teamAPlayerIds:
      (json['teamAPlayerIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  teamBPlayerIds:
      (json['teamBPlayerIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$TournamentMatchModelToJson(
  _TournamentMatchModel instance,
) => <String, dynamic>{
  'matchId': instance.matchId,
  'playerAName': instance.playerAName,
  'playerBName': instance.playerBName,
  'playerAUid': instance.playerAUid,
  'playerBUid': instance.playerBUid,
  'winnerUid': instance.winnerUid,
  'roomId': instance.roomId,
  'gameId': instance.gameId,
  'nextMatchId': instance.nextMatchId,
  'roundIndex': instance.roundIndex,
  'matchIndex': instance.matchIndex,
  'playerAScore': instance.playerAScore,
  'playerBScore': instance.playerBScore,
  'status': instance.status,
  'isUserMatch': instance.isUserMatch,
  'playerAAvatarUrl': instance.playerAAvatarUrl,
  'playerBAvatarUrl': instance.playerBAvatarUrl,
  'teamAPlayerIds': instance.teamAPlayerIds,
  'teamBPlayerIds': instance.teamBPlayerIds,
};

_TournamentModel _$TournamentModelFromJson(
  Map<String, dynamic> json,
) => _TournamentModel(
  id: json['id'] as String,
  name: json['name'] as String,
  prize: json['prize'] as String,
  participants: json['participants'] as String,
  status: json['status'] as String,
  date: json['date'] as String,
  isPremium: json['isPremium'] as bool? ?? false,
  isJoined: json['isJoined'] as bool? ?? false,
  prizes:
      (json['prizes'] as List<dynamic>?)
          ?.map((e) => TournamentPrizeModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  bracket:
      (json['bracket'] as List<dynamic>?)
          ?.map((e) => TournamentMatchModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  entryFee: json['entryFee'] as String? ?? '',
  participantIds:
      (json['participantIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 64,
  currentRound: (json['currentRound'] as num?)?.toInt() ?? 0,
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  endedAt: json['endedAt'] == null
      ? null
      : DateTime.parse(json['endedAt'] as String),
  creatorUid: json['creatorUid'] as String?,
  format: json['format'] as String? ?? 'single_elimination',
);

Map<String, dynamic> _$TournamentModelToJson(_TournamentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'prize': instance.prize,
      'participants': instance.participants,
      'status': instance.status,
      'date': instance.date,
      'isPremium': instance.isPremium,
      'isJoined': instance.isJoined,
      'prizes': instance.prizes,
      'bracket': instance.bracket,
      'entryFee': instance.entryFee,
      'participantIds': instance.participantIds,
      'maxParticipants': instance.maxParticipants,
      'currentRound': instance.currentRound,
      'startedAt': instance.startedAt?.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'creatorUid': instance.creatorUid,
      'format': instance.format,
    };
