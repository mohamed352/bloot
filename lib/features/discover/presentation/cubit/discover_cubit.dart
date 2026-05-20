import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/discover/domain/repositories/discover_repository.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_state.dart';

@injectable
class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit({required DiscoverRepository discoverRepository})
    : _discoverRepository = discoverRepository,
      super(const DiscoverState.initial());

  final DiscoverRepository _discoverRepository;

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
    try {
      final stream = await _discoverRepository.getStreamById(id);
      final messages = await _discoverRepository.sendChatMessage(id, '');
      emit(DiscoverState.streamLoaded(stream: stream, messages: messages));
    } catch (e) {
      AppLogger.error('Failed to load stream', error: e);
      emit(const DiscoverState.error(message: 'Failed to load stream.'));
    }
  }

  Future<void> sendChatMessage(String streamId, String message) async {
    final currentState = state;
    if (currentState is! DiscoverStreamLoaded) return;
    try {
      final messages = await _discoverRepository.sendChatMessage(
        streamId,
        message,
      );
      emit(
        DiscoverState.streamLoaded(
          stream: currentState.stream,
          messages: messages,
        ),
      );
    } catch (e) {
      AppLogger.error('Failed to send message', error: e);
    }
  }
}
