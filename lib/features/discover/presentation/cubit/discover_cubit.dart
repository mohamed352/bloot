import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/discover/domain/entities/discover_stream.dart';
import 'package:bloot/features/discover/domain/repositories/discover_repository.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_state.dart';

@injectable
class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit({required DiscoverRepository discoverRepository})
    : _discoverRepository = discoverRepository,
      super(const DiscoverState.initial());

  final DiscoverRepository _discoverRepository;
  StreamSubscription<List<StreamChatMessage>>? _chatSubscription;

  Future<void> loadStreams() async {
    emit(const DiscoverState.loading());
    try {
      final streams = await _discoverRepository.getStreams();
      emit(DiscoverState.streamsLoaded(streams: streams));
    } catch (e) {
      AppLogger.error('Failed to load streams', error: e);
      emit(const DiscoverState.error(message: 'Failed to load streams.'));
    }
  }

  void selectFilter(int index) {
    final currentState = state;
    if (currentState is! DiscoverStreamsLoaded) return;
    emit(currentState.copyWith(selectedFilterIndex: index));
  }

  Future<void> loadStream(String id) async {
    emit(const DiscoverState.loading());
    await _chatSubscription?.cancel();
    _chatSubscription = null;

    try {
      final stream = await _discoverRepository.getStreamById(id);
      // Emit the stream immediately so the UI is not stuck in loading if the
      // chat stream is empty or slow to emit.
      emit(DiscoverState.streamLoaded(stream: stream, messages: const []));
      _chatSubscription = _discoverRepository.watchStreamChat(id).listen(
        (messages) {
          if (isClosed) return;
          emit(DiscoverState.streamLoaded(stream: stream, messages: messages));
        },
        onError: (Object e) {
          AppLogger.error('Failed to watch stream chat', error: e);
          if (!isClosed) {
            emit(const DiscoverState.error(message: 'Failed to load stream chat.'));
          }
        },
      );
    } catch (e) {
      AppLogger.error('Failed to load stream', error: e);
      emit(const DiscoverState.error(message: 'Failed to load stream.'));
    }
  }

  Future<void> sendChatMessage(String streamId, String message) async {
    try {
      await _discoverRepository.sendChatMessage(streamId, message);
    } catch (e) {
      AppLogger.error('Failed to send message', error: e);
    }
  }

  @override
  Future<void> close() async {
    await _chatSubscription?.cancel();
    _chatSubscription = null;
    return super.close();
  }
}
