import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/tournament/domain/entities/tournament.dart';

part 'tournament_model.freezed.dart';
part 'tournament_model.g.dart';

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
  );
}
