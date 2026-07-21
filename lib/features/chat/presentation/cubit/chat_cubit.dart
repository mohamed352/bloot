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

  /// Clears the unread badge for [conversationId].
  Future<void> markAsRead(String conversationId) async {
    try {
      await _chatRepository.markConversationRead(conversationId);
    } catch (e) {
      AppLogger.error('Failed to mark conversation as read', error: e);
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
            // The conversation is open: incoming messages are seen
            // immediately, so keep the unread badge cleared. Own sends
            // already reset it server-side, so skip the extra write.
            if (messages.isNotEmpty && !messages.first.isMe) {
              unawaited(_chatRepository.markConversationRead(conversationId));
            }
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
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;

    final currentState = state;
    ChatMessage? optimisticMessage;

    // Optimistically add the message to the local list so the user sees it
    // immediately, even before Firestore resolves the server timestamp.
    if (currentState is ChatMessagesLoaded) {
      final now = DateTime.now();
      final time =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      optimisticMessage = ChatMessage(
        id: 'local_${now.millisecondsSinceEpoch}',
        text: trimmed,
        isMe: true,
        time: time,
      );
      emit(
        ChatState.messagesLoaded(
          conversationId: currentState.conversationId,
          messages: [optimisticMessage, ...currentState.messages],
        ),
      );
    }

    try {
      await _chatRepository.sendMessage(conversationId, trimmed);
    } catch (e) {
      AppLogger.error('Failed to send message', error: e);

      // Remove the optimistic message on failure so the user knows it didn't
      // go through.
      if (optimisticMessage != null && state is ChatMessagesLoaded) {
        final loadedState = state as ChatMessagesLoaded;
        emit(
          ChatState.messagesLoaded(
            conversationId: loadedState.conversationId,
            messages: loadedState.messages
                .where((m) => m.id != optimisticMessage!.id)
                .toList(),
          ),
        );
      }

      emit(const ChatState.error(message: 'Failed to send message.'));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
