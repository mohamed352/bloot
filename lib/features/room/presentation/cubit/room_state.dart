import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/room/domain/entities/room.dart';

part 'room_state.freezed.dart';

@freezed
class RoomState with _$RoomState {
  const factory RoomState.initial() = RoomInitial;
  const factory RoomState.loading() = RoomLoading;
  const factory RoomState.loaded({required Room room}) = RoomLoaded;
  const factory RoomState.created({required Room room}) = RoomCreated;
  const factory RoomState.gameStarted({required String gameId}) =
      RoomGameStarted;
  const factory RoomState.publicListLoaded({required List<Room> rooms}) =
      RoomPublicListLoaded;
  const factory RoomState.error({required String message}) = RoomError;
}
