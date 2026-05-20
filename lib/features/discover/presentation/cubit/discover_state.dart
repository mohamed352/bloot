import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/discover/domain/entities/discover_stream.dart';

part 'discover_state.freezed.dart';

@freezed
class DiscoverState with _$DiscoverState {
  const factory DiscoverState.initial() = DiscoverInitial;
  const factory DiscoverState.loading() = DiscoverLoading;
  const factory DiscoverState.streamsLoaded({
    required List<DiscoverStream> streams,
    @Default(0) int selectedFilterIndex,
  }) = DiscoverStreamsLoaded;
  const factory DiscoverState.streamLoaded({
    required DiscoverStream stream,
    required List<StreamChatMessage> messages,
  }) = DiscoverStreamLoaded;
  const factory DiscoverState.error({required String message}) = DiscoverError;
}
