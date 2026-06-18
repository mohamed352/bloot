import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/chat/domain/entities/chat.dart';
import 'package:bloot/features/chat/domain/repositories/chat_repository.dart';
import 'package:bloot/features/chat/presentation/cubit/chat_state.dart';

@injectable
class ChatCubit extends Cubit<ChatState> {
  ChatCubit({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(const ChatState.initial());

  final ChatRepository _chatRepository;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  Future<void> loadConversations() async {
    emit(const ChatState.loading());
    try {
      final conversations = await _chatRepository.getConversations();
      emit(ChatState.conversationsLoaded(conversations: conversations));
    } catch (e) {
      AppLogger.error('Failed to load conversations', error: e);
      emit(const ChatState.error(message: 'Failed to load conversations.'));
    }
  }

  void selectFilter(int index) {
    final currentState = state;
    if (currentState is! ChatConversationsLoaded) return;
    emit(currentState.copyWith(selectedFilterIndex: index));
  }

  void watchMessages(String conversationId) {
    emit(const ChatState.loading());
    _messagesSubscription?.cancel();
    // Emit an empty loaded state immediately so empty conversations do not
    // stay stuck in loading.
    emit(
      ChatState.messagesLoaded(
        conversationId: conversationId,
        messages: const [],
      ),
    );
    _messagesSubscription = _chatRepository
        .watchMessages(conversationId)
        .listen(
          (messages) {
            if (isClosed) return;
            emit(
              ChatState.messagesLoaded(
                conversationId: conversationId,
                messages: messages,
              ),
            );
          },
          onError: (Object e) {
            AppLogger.error('Failed to watch messages', error: e);
            if (!isClosed) {
              emit(const ChatState.error(message: 'Failed to load messages.'));
            }
          },
        );
  }

  Future<void> loadMessages(String conversationId) async {
    emit(const ChatState.loading());
    try {
      final messages = await _chatRepository.getMessages(conversationId);
      emit(
        ChatState.messagesLoaded(
          conversationId: conversationId,
          messages: messages,
        ),
      );
    } catch (e) {
      AppLogger.error('Failed to load messages', error: e);
      emit(const ChatState.error(message: 'Failed to load messages.'));
    }
  }

  Future<void> sendMessage(String conversationId, String message) async {
    try {
      await _chatRepository.sendMessage(conversationId, message);
    } catch (e) {
      AppLogger.error('Failed to send message', error: e);
      emit(const ChatState.error(message: 'Failed to send message.'));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
