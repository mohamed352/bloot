import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/discover/domain/entities/discover_stream.dart';

part 'discover_stream_model.freezed.dart';
part 'discover_stream_model.g.dart';

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
  }) = _DiscoverStreamModel;

  factory DiscoverStreamModel.fromJson(Map<String, dynamic> json) =>
      _$DiscoverStreamModelFromJson(json);
}

@freezed
abstract class StreamChatMessageModel with _$StreamChatMessageModel {
  const factory StreamChatMessageModel({
    required String user,
    required String text,
    @Default(false) bool isMe,
  }) = _StreamChatMessageModel;

  factory StreamChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$StreamChatMessageModelFromJson(json);
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
  );
}

extension StreamChatMessageModelX on StreamChatMessageModel {
  StreamChatMessage toEntity() =>
      StreamChatMessage(user: user, text: text, isMe: isMe);
}
