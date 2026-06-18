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
  mySeatIndex: (json['mySeatIndex'] as num?)?.toInt() ?? 0,
  playedCards: (json['playedCards'] as List<dynamic>)
      .map((e) => e as String?)
      .toList(),
  scoreUs: (json['scoreUs'] as num).toInt(),
  scoreThem: (json['scoreThem'] as num).toInt(),
  teamAScore: (json['teamAScore'] as num?)?.toInt() ?? 0,
  teamBScore: (json['teamBScore'] as num?)?.toInt() ?? 0,
  trump: json['trump'] as String,
  status: json['status'] as String,
  turnIndex: (json['turnIndex'] as num).toInt(),
  currentRound: (json['currentRound'] as num).toInt(),
  targetScore: (json['targetScore'] as num).toInt(),
  gameType: json['gameType'] as String?,
  dealerIndex: (json['dealerIndex'] as num?)?.toInt() ?? 0,
  faceUpCard: json['faceUpCard'] as String?,
  biddingTeam: json['biddingTeam'] as String?,
  fellTeam: json['fellTeam'] as String?,
  currentTrick: json['currentTrick'] == null
      ? null
      : TrickModel.fromJson(json['currentTrick'] as Map<String, dynamic>),
  roomId: json['roomId'] as String?,
  agoraChannelName: json['agoraChannelName'] as String?,
);

Map<String, dynamic> _$GameModelToJson(_GameModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'players': instance.players,
      'myHand': instance.myHand,
      'mySeatIndex': instance.mySeatIndex,
      'playedCards': instance.playedCards,
      'scoreUs': instance.scoreUs,
      'scoreThem': instance.scoreThem,
      'teamAScore': instance.teamAScore,
      'teamBScore': instance.teamBScore,
      'trump': instance.trump,
      'status': instance.status,
      'turnIndex': instance.turnIndex,
      'currentRound': instance.currentRound,
      'targetScore': instance.targetScore,
      'gameType': instance.gameType,
      'dealerIndex': instance.dealerIndex,
      'faceUpCard': instance.faceUpCard,
      'biddingTeam': instance.biddingTeam,
      'fellTeam': instance.fellTeam,
      'currentTrick': instance.currentTrick,
      'roomId': instance.roomId,
      'agoraChannelName': instance.agoraChannelName,
    };

_GamePlayerModel _$GamePlayerModelFromJson(Map<String, dynamic> json) =>
    _GamePlayerModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
      team: json['team'] as String,
      seatIndex: (json['seatIndex'] as num).toInt(),
      hand:
          (json['hand'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      takenCards:
          (json['takenCards'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      tricksWon: (json['tricksWon'] as num?)?.toInt() ?? 0,
      bid: json['bid'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      isMuted: json['isMuted'] as bool? ?? false,
      hasCamera: json['hasCamera'] as bool? ?? true,
      isTop: json['isTop'] as bool? ?? false,
      isConnected: json['isConnected'] as bool? ?? true,
      agoraUid: (json['agoraUid'] as num?)?.toInt(),
      isSpeaking: json['isSpeaking'] as bool? ?? false,
    );

Map<String, dynamic> _$GamePlayerModelToJson(_GamePlayerModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'team': instance.team,
      'seatIndex': instance.seatIndex,
      'hand': instance.hand,
      'takenCards': instance.takenCards,
      'tricksWon': instance.tricksWon,
      'bid': instance.bid,
      'isActive': instance.isActive,
      'isMuted': instance.isMuted,
      'hasCamera': instance.hasCamera,
      'isTop': instance.isTop,
      'isConnected': instance.isConnected,
      'agoraUid': instance.agoraUid,
      'isSpeaking': instance.isSpeaking,
    };

_TrickModel _$TrickModelFromJson(Map<String, dynamic> json) => _TrickModel(
  trickNumber: (json['trickNumber'] as num).toInt(),
  trickLeaderIndex: (json['trickLeaderIndex'] as num).toInt(),
  leadingSuit: json['leadingSuit'] as String?,
  cards:
      (json['cards'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String?),
      ) ??
      const <String, String?>{},
  winnerSeat: (json['winnerSeat'] as num?)?.toInt(),
);

Map<String, dynamic> _$TrickModelToJson(_TrickModel instance) =>
    <String, dynamic>{
      'trickNumber': instance.trickNumber,
      'trickLeaderIndex': instance.trickLeaderIndex,
      'leadingSuit': instance.leadingSuit,
      'cards': instance.cards,
      'winnerSeat': instance.winnerSeat,
    };
