import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/chat/domain/repositories/chat_repository.dart';
import 'package:bloot/features/chat/presentation/cubit/chat_state.dart';

@injectable
class ChatCubit extends Cubit<ChatState> {
  ChatCubit({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(const ChatState.initial());

  final ChatRepository _chatRepository;

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
    final currentState = state;
    if (currentState is! ChatMessagesLoaded) return;
    try {
      final messages = await _chatRepository.sendMessage(
        conversationId,
        message,
      );
      emit(
        ChatState.messagesLoaded(
          conversationId: conversationId,
          messages: messages,
        ),
      );
    } catch (e) {
      AppLogger.error('Failed to send message', error: e);
    }
  }
}
