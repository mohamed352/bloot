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
  StreamSubscription<DiscoverStream>? _streamSubscription;
  DiscoverStream? _latestStream;
  List<StreamChatMessage> _latestMessages = const [];

  StreamSubscription<List<DiscoverStream>>? _streamsSubscription;

  Future<void> loadStreams() async {
    emit(const DiscoverState.loading());
    await _streamsSubscription?.cancel();
    try {
      _streamsSubscription = _discoverRepository.watchStreams().listen(
        (streams) {
          if (isClosed) return;
          emit(DiscoverState.streamsLoaded(streams: streams));
        },
        onError: (Object e) {
          AppLogger.error('Failed to watch streams', error: e);
          if (!isClosed) {
            emit(const DiscoverState.error(message: 'Failed to load streams.'));
          }
        },
      );
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
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    _latestStream = null;
    _latestMessages = const [];
    AppLogger.setCustomKey('streamId', id);

    try {
      final stream = await _discoverRepository.getStreamById(id);
      _latestStream = stream;
      // Emit the stream immediately so the UI is not stuck in loading if the
      // chat stream is empty or slow to emit.
      emit(DiscoverState.streamLoaded(stream: stream, messages: const []));

      // Subscribe to real-time stream document updates so watchers see live
      // player camera/mic state changes and stream status transitions.
      _streamSubscription = _discoverRepository
          .watchStream(id)
          .listen(
            (updatedStream) {
              if (isClosed) return;
              _latestStream = updatedStream;
              emit(
                DiscoverState.streamLoaded(
                  stream: updatedStream,
                  messages: _latestMessages,
                ),
              );
            },
            onError: (Object e) {
              AppLogger.error('Failed to watch stream doc', error: e);
            },
          );

      _chatSubscription = _discoverRepository
          .watchStreamChat(id)
          .listen(
            (messages) {
              if (isClosed) return;
              _latestMessages = messages;
              final currentStream = _latestStream;
              if (currentStream != null) {
                emit(
                  DiscoverState.streamLoaded(
                    stream: currentStream,
                    messages: messages,
                  ),
                );
              }
            },
            onError: (Object e) {
              AppLogger.error('Failed to watch stream chat', error: e);
              if (!isClosed) {
                emit(
                  const DiscoverState.error(
                    message: 'Failed to load stream chat.',
                  ),
                );
              }
            },
          );
    } catch (e) {
      AppLogger.error('Failed to load stream', error: e);
      emit(const DiscoverState.error(message: 'Failed to load stream.'));
    }
  }

  /// Sends a chat message; returns `true` on success so the UI can keep the
  /// typed text (instead of clearing it) when the send fails.
  Future<bool> sendChatMessage(String streamId, String message) async {
    try {
      await _discoverRepository.sendChatMessage(streamId, message);
      return true;
    } catch (e) {
      AppLogger.error('Failed to send message', error: e);
      return false;
    }
  }

  /// Resolves a live stream by room invite [code]. Returns the stream id, or
  /// `null` when no live stream matches. Does not emit state changes.
  Future<String?> findStreamByCode(String code) {
    return _discoverRepository.findStreamIdByCode(code);
  }

  @override
  Future<void> close() async {
    await _chatSubscription?.cancel();
    _chatSubscription = null;
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    await _streamsSubscription?.cancel();
    _streamsSubscription = null;
    return super.close();
  }
}
