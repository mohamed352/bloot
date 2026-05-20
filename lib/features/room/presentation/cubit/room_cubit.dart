import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/room/domain/exceptions/room_exception.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';
import 'package:bloot/features/room/presentation/cubit/room_state.dart';

@injectable
class RoomCubit extends Cubit<RoomState> {
  RoomCubit({required RoomRepository roomRepository})
    : _roomRepository = roomRepository,
      super(const RoomState.initial());

  final RoomRepository _roomRepository;

  Future<void> createRoom(CreateRoomParams params) async {
    emit(const RoomState.loading());
    try {
      final room = await _roomRepository.createRoom(params);
      emit(RoomState.created(room: room));
    } on RoomException catch (e) {
      emit(RoomState.error(message: e.message));
    } catch (e) {
      AppLogger.error('Failed to create room', error: e);
      emit(
        const RoomState.error(
          message: 'Failed to create room. Please try again.',
        ),
      );
    }
  }

  Future<void> loadRoom(String roomId) async {
    emit(const RoomState.loading());
    try {
      final room = await _roomRepository.getRoomById(roomId);
      emit(RoomState.loaded(room: room));
    } on RoomException catch (e) {
      emit(RoomState.error(message: e.message));
    } catch (e) {
      AppLogger.error('Failed to load room', error: e);
      emit(
        const RoomState.error(
          message: 'Failed to load room. Please try again.',
        ),
      );
    }
  }

  Future<void> toggleReady(String roomId) async {
    final currentState = state;
    if (currentState is! RoomLoaded) return;
    try {
      final room = await _roomRepository.toggleReady(roomId);
      emit(RoomState.loaded(room: room));
    } on RoomException catch (e) {
      emit(RoomState.error(message: e.message));
      emit(currentState);
    } catch (e) {
      AppLogger.error('Failed to toggle ready', error: e);
      emit(const RoomState.error(message: 'Failed to update ready status.'));
      emit(currentState);
    }
  }

  void toggleChat() {
    final currentState = state;
    if (currentState is! RoomLoaded) return;
    emit(currentState.copyWith(chatOpen: !currentState.chatOpen));
  }

  Future<void> sendChatMessage(String roomId, String message) async {
    final currentState = state;
    if (currentState is! RoomLoaded) return;
    try {
      final room = await _roomRepository.sendChatMessage(roomId, message);
      emit(RoomState.loaded(room: room));
    } catch (e) {
      AppLogger.error('Failed to send message', error: e);
    }
  }
}
