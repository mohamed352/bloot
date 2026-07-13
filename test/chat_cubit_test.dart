import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/features/chat/domain/entities/chat.dart';
import 'package:bloot/features/chat/domain/repositories/chat_repository.dart';
import 'package:bloot/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:bloot/features/chat/presentation/cubit/chat_state.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository chatRepository;

  setUp(() {
    chatRepository = MockChatRepository();
  });

  const conversation = ChatConversation(
    id: 'c1',
    name: 'Ali',
    lastMessage: 'Hello',
    time: '2m',
    type: 'direct',
  );

  const message = ChatMessage(
    id: 'm1',
    text: 'Hi',
    time: '2m',
  );

  ChatCubit buildCubit() => ChatCubit(chatRepository: chatRepository);

  group('loadConversations', () {
    blocTest<ChatCubit, ChatState>(
      'emits loaded state with conversations',
      build: buildCubit,
      setUp: () {
        when(() => chatRepository.getConversations())
            .thenAnswer((_) async => [conversation]);
      },
      act: (cubit) => cubit.loadConversations(),
      expect: () => [
        const ChatState.loading(),
        const ChatState.conversationsLoaded(conversations: [conversation]),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'emits empty loaded state when no conversations',
      build: buildCubit,
      setUp: () {
        when(() => chatRepository.getConversations())
            .thenAnswer((_) async => []);
      },
      act: (cubit) => cubit.loadConversations(),
      expect: () => [
        const ChatState.loading(),
        const ChatState.conversationsLoaded(conversations: []),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'emits error when repository fails',
      build: buildCubit,
      setUp: () {
        when(() => chatRepository.getConversations())
            .thenThrow(Exception('network'));
      },
      act: (cubit) => cubit.loadConversations(),
      expect: () => [
        const ChatState.loading(),
        const ChatState.error(message: 'Failed to load conversations.'),
      ],
    );
  });

  group('selectFilter', () {
    blocTest<ChatCubit, ChatState>(
      'updates selected filter index',
      build: buildCubit,
      seed: () => const ChatState.conversationsLoaded(
        conversations: [conversation],
      ),
      act: (cubit) => cubit.selectFilter(2),
      expect: () => [
        const ChatState.conversationsLoaded(
          conversations: [conversation],
          selectedFilterIndex: 2,
        ),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'does nothing when not in conversations loaded state',
      build: buildCubit,
      act: (cubit) => cubit.selectFilter(1),
      expect: () => const <ChatState>[],
    );
  });

  group('watchMessages', () {
    blocTest<ChatCubit, ChatState>(
      'emits empty messages immediately then updates on stream events',
      build: () {
        when(() => chatRepository.watchMessages('c1')).thenAnswer(
          (_) => Stream.value([message]),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.watchMessages('c1'),
      expect: () => [
        const ChatState.loading(),
        const ChatState.messagesLoaded(
          conversationId: 'c1',
          messages: [],
        ),
        const ChatState.messagesLoaded(
          conversationId: 'c1',
          messages: [message],
        ),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'emits error when stream fails',
      build: () {
        when(() => chatRepository.watchMessages('c1'))
            .thenAnswer((_) => Stream.error(Exception('network')));
        return buildCubit();
      },
      act: (cubit) => cubit.watchMessages('c1'),
      expect: () => [
        const ChatState.loading(),
        const ChatState.messagesLoaded(
          conversationId: 'c1',
          messages: [],
        ),
        const ChatState.error(message: 'Failed to load messages.'),
      ],
    );
  });

  group('loadMessages', () {
    blocTest<ChatCubit, ChatState>(
      'emits loaded messages',
      build: buildCubit,
      setUp: () {
        when(() => chatRepository.getMessages('c1'))
            .thenAnswer((_) async => [message]);
      },
      act: (cubit) => cubit.loadMessages('c1'),
      expect: () => [
        const ChatState.loading(),
        const ChatState.messagesLoaded(
          conversationId: 'c1',
          messages: [message],
        ),
      ],
    );
  });

  group('sendMessage', () {
    blocTest<ChatCubit, ChatState>(
      'does not emit error on success when no messages loaded',
      build: buildCubit,
      setUp: () {
        when(() => chatRepository.sendMessage('c1', 'hello'))
            .thenAnswer((_) async {});
      },
      act: (cubit) => cubit.sendMessage('c1', 'hello'),
      expect: () => const <ChatState>[],
    );

    blocTest<ChatCubit, ChatState>(
      'optimistically adds message then removes it on failure',
      build: buildCubit,
      seed: () => const ChatState.messagesLoaded(
        conversationId: 'c1',
        messages: [message],
      ),
      setUp: () {
        when(() => chatRepository.sendMessage('c1', 'hello'))
            .thenThrow(Exception('network'));
      },
      act: (cubit) => cubit.sendMessage('c1', 'hello'),
      expect: () => [
        predicate<ChatState>((s) {
          return s is ChatMessagesLoaded &&
              s.messages.length == 2 &&
              s.messages.first.isMe == true &&
              s.messages.first.text == 'hello';
        }),
        const ChatState.messagesLoaded(
          conversationId: 'c1',
          messages: [message],
        ),
        const ChatState.error(message: 'Failed to send message.'),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'optimistically adds message on success',
      build: buildCubit,
      seed: () => const ChatState.messagesLoaded(
        conversationId: 'c1',
        messages: [message],
      ),
      setUp: () {
        when(() => chatRepository.sendMessage('c1', 'hello'))
            .thenAnswer((_) async {});
      },
      act: (cubit) => cubit.sendMessage('c1', 'hello'),
      expect: () => [
        predicate<ChatState>((s) {
          return s is ChatMessagesLoaded &&
              s.messages.length == 2 &&
              s.messages.first.isMe == true &&
              s.messages.first.text == 'hello';
        }),
      ],
    );
  });
}
