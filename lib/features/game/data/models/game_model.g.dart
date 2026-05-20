// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameModel _$GameModelFromJson(Map<String, dynamic> json) => _GameModel(
  id: json['id'] as String,
  players: (json['players'] as List<dynamic>)
      .map((e) => GamePlayerModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  myHand: (json['myHand'] as List<dynamic>).map((e) => e as String).toList(),
  playedCards: (json['playedCards'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  scoreUs: (json['scoreUs'] as num).toInt(),
  scoreThem: (json['scoreThem'] as num).toInt(),
  trump: json['trump'] as String,
);

Map<String, dynamic> _$GameModelToJson(_GameModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'players': instance.players,
      'myHand': instance.myHand,
      'playedCards': instance.playedCards,
      'scoreUs': instance.scoreUs,
      'scoreThem': instance.scoreThem,
      'trump': instance.trump,
    };

_GamePlayerModel _$GamePlayerModelFromJson(Map<String, dynamic> json) =>
    _GamePlayerModel(
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
      team: json['team'] as String,
      isActive: json['isActive'] as bool? ?? false,
      isMuted: json['isMuted'] as bool? ?? false,
      hasCamera: json['hasCamera'] as bool? ?? true,
      isTop: json['isTop'] as bool? ?? false,
    );

Map<String, dynamic> _$GamePlayerModelToJson(_GamePlayerModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'team': instance.team,
      'isActive': instance.isActive,
      'isMuted': instance.isMuted,
      'hasCamera': instance.hasCamera,
      'isTop': instance.isTop,
    };
