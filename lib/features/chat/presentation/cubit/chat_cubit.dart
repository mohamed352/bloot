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

  /// The live window of recent messages for the open conversation.
  List<ChatMessage> _liveMessages = [];

  /// Older messages appended via [loadOlderMessages], oldest page last.
  List<ChatMessage> _olderMessages = [];
  bool _hasMoreOlder = true;
  bool _loadingOlder = false;

  /// Whether another page of older messages may exist for the open
  /// conversation.
  bool get hasMoreOlder => _hasMoreOlder;

  /// Whether a page of older messages is currently being fetched.
  bool get isLoadingOlder => _loadingOlder;

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
    _liveMessages = [];
    _olderMessages = [];
    _hasMoreOlder = true;
    _loadingOlder = false;
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
            _liveMessages = messages;
            _emitMessages(conversationId);
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

  /// Emits the live window plus any paged older messages as one list.
  void _emitMessages(String conversationId) {
    if (isClosed) return;
    emit(
      ChatState.messagesLoaded(
        conversationId: conversationId,
        messages: [..._liveMessages, ..._olderMessages],
      ),
    );
  }

  /// Loads the next page of older messages for [conversationId] and appends
  /// them after the live window. No-op while a page is in flight or when
  /// the history has been fully loaded.
  Future<void> loadOlderMessages(String conversationId) async {
    if (_loadingOlder || !_hasMoreOlder) return;
    final currentState = state;
    if (currentState is! ChatMessagesLoaded ||
        currentState.conversationId != conversationId) {
      return;
    }

    _loadingOlder = true;
    try {
      final older = await _chatRepository.getOlderMessages(conversationId);
      if (isClosed) return;
      if (older.isEmpty) {
        _hasMoreOlder = false;
        return;
      }
      final knownIds = <String>{
        ..._liveMessages.map((m) => m.id),
        ..._olderMessages.map((m) => m.id),
      };
      _olderMessages = [
        ..._olderMessages,
        ...older.where((m) => !knownIds.contains(m.id)),
      ];
      _emitMessages(conversationId);
    } catch (e) {
      AppLogger.error('Failed to load older messages', error: e);
    } finally {
      _loadingOlder = false;
    }
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
