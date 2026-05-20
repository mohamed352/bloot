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
    required List<String> playedCards,
    required int scoreUs,
    required int scoreThem,
    required String trump,
  }) = _GameModel;

  factory GameModel.fromJson(Map<String, dynamic> json) =>
      _$GameModelFromJson(json);
}

@freezed
abstract class GamePlayerModel with _$GamePlayerModel {
  const factory GamePlayerModel({
    required String name,
    required String avatarUrl,
    required String team,
    @Default(false) bool isActive,
    @Default(false) bool isMuted,
    @Default(true) bool hasCamera,
    @Default(false) bool isTop,
  }) = _GamePlayerModel;

  factory GamePlayerModel.fromJson(Map<String, dynamic> json) =>
      _$GamePlayerModelFromJson(json);
}

extension GamePlayerModelX on GamePlayerModel {
  GamePlayer toEntity() => GamePlayer(
    name: name,
    avatarUrl: avatarUrl,
    team: team,
    isActive: isActive,
    isMuted: isMuted,
    hasCamera: hasCamera,
    isTop: isTop,
  );
}

extension GameModelX on GameModel {
  Game toEntity() => Game(
    id: id,
    players: players.map((p) => p.toEntity()).toList(),
    myHand: myHand,
    playedCards: playedCards,
    scoreUs: scoreUs,
    scoreThem: scoreThem,
    trump: trump,
  );
}
