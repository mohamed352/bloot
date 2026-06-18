import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/discover/domain/entities/discover_stream.dart';

part 'discover_stream_model.freezed.dart';
part 'discover_stream_model.g.dart';

@freezed
abstract class StreamPlayerModel with _$StreamPlayerModel {
  const factory StreamPlayerModel({
    required String uid,
    required String name,
    String? avatarUrl,
    required int agoraUid,
    @Default('A') String team,
    @Default(false) bool isCameraOn,
    @Default(true) bool isMicOn,
  }) = _StreamPlayerModel;

  factory StreamPlayerModel.fromJson(Map<String, dynamic> json) =>
      _$StreamPlayerModelFromJson(json);
}

@freezed
abstract class DiscoverStreamModel with _$DiscoverStreamModel {
  const factory DiscoverStreamModel({
    required String id,
    required String title,
    required String host,
    required int viewers,
    required String avatarUrl,
    @Default('Baloot') String category,
    @Default(true) bool isLive,
    @Default(false) bool isPremium,
    String? agoraChannelName,
    String? roomId,
    @Default([]) List<StreamPlayerModel> players,
  }) = _DiscoverStreamModel;

  factory DiscoverStreamModel.fromJson(Map<String, dynamic> json) =>
      _$DiscoverStreamModelFromJson(json);
}

@freezed
abstract class StreamChatMessageModel with _$StreamChatMessageModel {
  const factory StreamChatMessageModel({
    required String id,
    required String senderUid,
    required String senderName,
    String? senderAvatar,
    required String text,
    @Default('text') String type,
    DateTime? createdAt,
    @Default(false) bool isMe,
  }) = _StreamChatMessageModel;

  factory StreamChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$StreamChatMessageModelFromJson(json);
}

extension StreamPlayerModelX on StreamPlayerModel {
  StreamPlayer toEntity() => StreamPlayer(
        uid: uid,
        name: name,
        avatarUrl: avatarUrl,
        agoraUid: agoraUid,
        team: team,
        isCameraOn: isCameraOn,
        isMicOn: isMicOn,
      );
}

extension DiscoverStreamModelX on DiscoverStreamModel {
  DiscoverStream toEntity() => DiscoverStream(
        id: id,
        title: title,
        host: host,
        viewers: viewers,
        avatarUrl: avatarUrl,
        category: category,
        isLive: isLive,
        isPremium: isPremium,
        agoraChannelName: agoraChannelName,
        roomId: roomId,
        players: players.map((p) => p.toEntity()).toList(),
      );
}

extension StreamChatMessageModelX on StreamChatMessageModel {
  StreamChatMessage toEntity() => StreamChatMessage(
        id: id,
        senderUid: senderUid,
        senderName: senderName,
        senderAvatar: senderAvatar,
        text: text,
        type: type,
        createdAt: createdAt,
        isMe: isMe,
      );
}
