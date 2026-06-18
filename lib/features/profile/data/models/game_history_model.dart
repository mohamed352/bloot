import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/profile/domain/entities/game_history.dart';

part 'game_history_model.freezed.dart';
part 'game_history_model.g.dart';

@freezed
abstract class GameHistoryModel with _$GameHistoryModel {
  const factory GameHistoryModel({
    required String id,
    required bool won,
    required String score,
    required String type,
    int? durationMinutes,
    DateTime? playedAt,
  }) = _GameHistoryModel;

  factory GameHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$GameHistoryModelFromJson(json);
}

extension GameHistoryModelX on GameHistoryModel {
  GameHistory toEntity() => GameHistory(
        id: id,
        won: won,
        score: score,
        type: type,
        durationMinutes: durationMinutes,
        playedAt: playedAt,
      );
}
