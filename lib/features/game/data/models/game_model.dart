import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/game/domain/entities/game.dart';

part 'game_model.freezed.dart';
part 'game_model.g.dart';

@freezed
abstract class GameModel with _$GameModel {
  const factory GameModel({
    required String id,
    required List<GamePlayerModel> players,
    required List<String> myHand,
    @Default(0) int mySeatIndex,
    required List<String?> playedCards,
    required int scoreUs,
    required int scoreThem,
    @Default(0) int teamAScore,
    @Default(0) int teamBScore,
    required String trump,
    required String status,
    required int turnIndex,
    required int currentRound,
    required int targetScore,
    String? gameType,
    @Default(0) int dealerIndex,
    String? faceUpCard,
    String? biddingTeam,
    String? fellTeam,
    TrickModel? currentTrick,
    String? roomId,
    String? agoraChannelName,
    @Default(false) bool voiceEnabled,
    @Default(false) bool cameraEnabled,
    Map<String, dynamic>? engineState,
  }) = _GameModel;

  factory GameModel.fromJson(Map<String, dynamic> json) =>
      _$GameModelFromJson(json);
}

@freezed
abstract class GamePlayerModel with _$GamePlayerModel {
  const factory GamePlayerModel({
    required String uid,
    required String name,
    required String avatarUrl,
    required String team,
    required int seatIndex,
    @Default(<String>[]) List<String> hand,
    @Default(<String>[]) List<String> takenCards,
    @Default(0) int tricksWon,
    String? bid,
    @Default(false) bool isActive,
    @Default(false) bool isMuted,
    @Default(true) bool hasCamera,
    @Default(false) bool isTop,
    @Default(true) bool isConnected,
    int? agoraUid,
    @Default(false) bool isSpeaking,
  }) = _GamePlayerModel;

  factory GamePlayerModel.fromJson(Map<String, dynamic> json) =>
      _$GamePlayerModelFromJson(json);
}

@freezed
abstract class TrickModel with _$TrickModel {
  const factory TrickModel({
    required int trickNumber,
    required int trickLeaderIndex,
    String? leadingSuit,
    @Default(<String, String?>{}) Map<String, String?> cards,
    int? winnerSeat,
  }) = _TrickModel;

  factory TrickModel.fromJson(Map<String, dynamic> json) =>
      _$TrickModelFromJson(json);
}

extension GamePlayerModelX on GamePlayerModel {
  GamePlayer toEntity() => GamePlayer(
    uid: uid,
    name: name,
    avatarUrl: avatarUrl,
    team: team,
    seatIndex: seatIndex,
    hand: hand,
    takenCards: takenCards,
    tricksWon: tricksWon,
    bid: bid,
    isActive: isActive,
    isMuted: isMuted,
    hasCamera: hasCamera,
    isTop: isTop,
    isConnected: isConnected,
    agoraUid: agoraUid ?? uid.hashCode.abs(),
    isSpeaking: isSpeaking,
  );
}

extension TrickModelX on TrickModel {
  Trick toEntity() => Trick(
    trickNumber: trickNumber,
    trickLeaderIndex: trickLeaderIndex,
    leadingSuit: leadingSuit,
    cards: cards,
    winnerSeat: winnerSeat,
  );
}

extension GameModelX on GameModel {
  Game toEntity({int? mySeatIndexOverride}) {
    final effectiveSeat = mySeatIndexOverride ?? mySeatIndex;
    final localTeam = players
        .firstWhere(
          (p) => p.seatIndex == effectiveSeat,
          orElse: () => players.first,
        )
        .team;
    final isTeamA = localTeam == 'A';

    return Game(
      id: id,
      players: players.map((p) => p.toEntity()).toList(),
      myHand: mySeatIndexOverride != null
          ? players
                .firstWhere(
                  (p) => p.seatIndex == mySeatIndexOverride,
                  orElse: () => players.first,
                )
                .hand
          : myHand,
      mySeatIndex: effectiveSeat,
      playedCards: playedCards,
      scoreUs: isTeamA ? teamAScore : teamBScore,
      scoreThem: isTeamA ? teamBScore : teamAScore,
      teamAScore: teamAScore,
      teamBScore: teamBScore,
      trump: trump,
      status: status,
      turnIndex: turnIndex,
      currentRound: currentRound,
      targetScore: targetScore,
      gameType: gameType,
      dealerIndex: dealerIndex,
      faceUpCard: faceUpCard,
      biddingTeam: biddingTeam,
      fellTeam: fellTeam,
      currentTrick: currentTrick?.toEntity(),
      roomId: roomId,
      agoraChannelName: agoraChannelName,
      voiceEnabled: voiceEnabled,
      cameraEnabled: cameraEnabled,
      engineState: engineState,
    );
  }
}
