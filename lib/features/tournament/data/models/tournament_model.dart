import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/tournament/domain/entities/tournament.dart';

part 'tournament_model.freezed.dart';
part 'tournament_model.g.dart';

@freezed
abstract class TournamentPrizeModel with _$TournamentPrizeModel {
  const factory TournamentPrizeModel({
    required String place,
    required String amount,
  }) = _TournamentPrizeModel;

  factory TournamentPrizeModel.fromJson(Map<String, dynamic> json) =>
      _$TournamentPrizeModelFromJson(json);
}

extension TournamentPrizeModelX on TournamentPrizeModel {
  TournamentPrize toEntity() => TournamentPrize(place: place, amount: amount);
}

@freezed
abstract class TournamentMatchModel with _$TournamentMatchModel {
  const factory TournamentMatchModel({
    required String matchId,
    required String playerAName,
    required String playerBName,
    String? playerAUid,
    String? playerBUid,
    String? winnerUid,
    String? roomId,
    String? gameId,
    String? nextMatchId,
    @Default(0) int roundIndex,
    @Default(0) int matchIndex,
    int? playerAScore,
    int? playerBScore,
    @Default('upcoming') String status,
    @Default(false) bool isUserMatch,
    String? playerAAvatarUrl,
    String? playerBAvatarUrl,
    @Default([]) List<String> teamAPlayerIds,
    @Default([]) List<String> teamBPlayerIds,
  }) = _TournamentMatchModel;

  factory TournamentMatchModel.fromJson(Map<String, dynamic> json) =>
      _$TournamentMatchModelFromJson(json);
}

extension TournamentMatchModelX on TournamentMatchModel {
  TournamentMatch toEntity() => TournamentMatch(
    matchId: matchId,
    playerAName: playerAName,
    playerBName: playerBName,
    playerAUid: playerAUid,
    playerBUid: playerBUid,
    winnerUid: winnerUid,
    roomId: roomId,
    gameId: gameId,
    nextMatchId: nextMatchId,
    roundIndex: roundIndex,
    matchIndex: matchIndex,
    playerAScore: playerAScore,
    playerBScore: playerBScore,
    status: status,
    isUserMatch: isUserMatch,
    playerAAvatarUrl: playerAAvatarUrl,
    playerBAvatarUrl: playerBAvatarUrl,
    teamAPlayerIds: teamAPlayerIds,
    teamBPlayerIds: teamBPlayerIds,
  );
}

@freezed
abstract class TournamentModel with _$TournamentModel {
  const factory TournamentModel({
    required String id,
    required String name,
    required String prize,
    required String participants,
    required String status,
    required String date,
    @Default(false) bool isPremium,
    @Default(false) bool isJoined,
    @Default([]) List<TournamentPrizeModel> prizes,
    @Default([]) List<TournamentMatchModel> bracket,
    @Default('') String entryFee,
    @Default([]) List<String> participantIds,
    @Default(64) int maxParticipants,
    @Default(0) int currentRound,
    DateTime? startedAt,
    DateTime? endedAt,
    String? creatorUid,
    @Default('single_elimination') String format,
  }) = _TournamentModel;

  factory TournamentModel.fromJson(Map<String, dynamic> json) =>
      _$TournamentModelFromJson(json);
}

extension TournamentModelX on TournamentModel {
  Tournament toEntity() => Tournament(
    id: id,
    name: name,
    prize: prize,
    participants: participants,
    status: status,
    date: date,
    isPremium: isPremium,
    isJoined: isJoined,
    prizes: prizes.map((p) => p.toEntity()).toList(),
    bracket: bracket.map((m) => m.toEntity()).toList(),
    entryFee: entryFee,
    participantIds: participantIds,
    maxParticipants: maxParticipants,
    currentRound: currentRound,
    startedAt: startedAt,
    endedAt: endedAt,
    creatorUid: creatorUid,
    format: format,
  );
}
