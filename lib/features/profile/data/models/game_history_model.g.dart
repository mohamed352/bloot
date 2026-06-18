// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameHistoryModel _$GameHistoryModelFromJson(Map<String, dynamic> json) =>
    _GameHistoryModel(
      id: json['id'] as String,
      won: json['won'] as bool,
      score: json['score'] as String,
      type: json['type'] as String,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      playedAt: json['playedAt'] == null
          ? null
          : DateTime.parse(json['playedAt'] as String),
    );

Map<String, dynamic> _$GameHistoryModelToJson(_GameHistoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'won': instance.won,
      'score': instance.score,
      'type': instance.type,
      'durationMinutes': instance.durationMinutes,
      'playedAt': instance.playedAt?.toIso8601String(),
    };
