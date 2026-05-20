// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TournamentModel _$TournamentModelFromJson(Map<String, dynamic> json) =>
    _TournamentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      prize: json['prize'] as String,
      participants: json['participants'] as String,
      status: json['status'] as String,
      date: json['date'] as String,
      isPremium: json['isPremium'] as bool? ?? false,
      isJoined: json['isJoined'] as bool? ?? false,
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
    };
