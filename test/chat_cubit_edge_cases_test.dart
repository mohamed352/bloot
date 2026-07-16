import 'dart:async';

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

  const message2 = ChatMessage(
    id: 'm2',
    text: 'How are you?',
    time: '1m',
  );

  ChatCubit buildCubit() => ChatCubit(chatRepository: chatRepository);

  group('sendMessage with empty text', () {
    blocTest<ChatCubit, ChatState>(
      'does nothing with empty string',
      build: buildCubit,
      seed: () => const ChatState.messagesLoaded(
        conversationId: 'c1',
        messages: [message],
      ),
      act: (cubit) => cubit.sendMessage('c1', ''),
      expect: () => const <ChatState>[],
      verify: (_) {
        verifyNever(() => chatRepository.sendMessage(any(), any()));
      },
    );

    blocTest<ChatCubit, ChatState>(
      'does nothing with whitespace-only text',
      build: buildCubit,
      seed: () => const ChatState.messagesLoaded(
        conversationId: 'c1',
        messages: [message],
      ),
      act: (cubit) => cubit.sendMessage('c1', '   '),
      expect: () => const <ChatState>[],
      verify: (_) {
        verifyNever(() => chatRepository.sendMessage(any(), any()));
      },
    );
  });

  group('sendMessage optimistic add when not in messagesLoaded state', () {
    blocTest<ChatCubit, ChatState>(
      'does not add optimistic message when in initial state',
      build: () {
        when(() => chatRepository.sendMessage('c1', 'hello'))
            .thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) => cubit.sendMessage('c1', 'hello'),
      expect: () => const <ChatState>[],
      verify: (_) {
        verify(() => chatRepository.sendMessage('c1', 'hello')).called(1);
      },
    );
  });

  group('sendMessage failure removes optimistic message with multiple messages', () {
    blocTest<ChatCubit, ChatState>(
      'removes only the optimistic message, keeps existing ones',
      build: () {
        when(() => chatRepository.sendMessage('c1', 'hello'))
            .thenThrow(Exception('network'));
        return buildCubit();
      },
      seed: () => const ChatState.messagesLoaded(
        conversationId: 'c1',
        messages: [message, message2],
      ),
      act: (cubit) => cubit.sendMessage('c1', 'hello'),
      expect: () => [
        predicate<ChatState>((s) {
          return s is ChatMessagesLoaded &&
              s.messages.length == 3 &&
              s.messages.first.isMe == true &&
              s.messages.first.text == 'hello';
        }),
        const ChatState.messagesLoaded(
          conversationId: 'c1',
          messages: [message, message2],
        ),
        const ChatState.error(message: 'Failed to send message.'),
      ],
    );
  });

  group('watchMessages re-entrancy', () {
    blocTest<ChatCubit, ChatState>(
      'calling watchMessages twice cancels previous subscription',
      build: () {
        when(() => chatRepository.watchMessages('c1'))
            .thenAnswer((_) => Stream.value([message]));
        when(() => chatRepository.watchMessages('c2'))
            .thenAnswer((_) => Stream.value([message2]));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchMessages('c1');
        await Future<void>.delayed(Duration.zero);
        cubit.watchMessages('c2');
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const ChatState.loading(),
        const ChatState.messagesLoaded(conversationId: 'c1', messages: []),
        const ChatState.messagesLoaded(conversationId: 'c1', messages: [message]),
        const ChatState.loading(),
        const ChatState.messagesLoaded(conversationId: 'c2', messages: []),
        const ChatState.messagesLoaded(conversationId: 'c2', messages: [message2]),
      ],
    );
  });

  group('loadMessages error', () {
    blocTest<ChatCubit, ChatState>(
      'emits error when repository fails',
      build: () {
        when(() => chatRepository.getMessages('c1'))
            .thenThrow(Exception('network'));
        return buildCubit();
      },
      act: (cubit) => cubit.loadMessages('c1'),
      expect: () => [
        const ChatState.loading(),
        const ChatState.error(message: 'Failed to load messages.'),
      ],
    );
  });

  group('close cleanup', () {
    blocTest<ChatCubit, ChatState>(
      'close cancels message subscription without errors',
      build: () {
        when(() => chatRepository.watchMessages('c1'))
            .thenAnswer((_) => const Stream.empty());
        return buildCubit();
      },
      act: (cubit) async {
        cubit.watchMessages('c1');
        await Future<void>.delayed(Duration.zero);
        await cubit.close();
      },
    );
  });

  group('sendMessage success with existing messages', () {
    blocTest<ChatCubit, ChatState>(
      'optimistically adds message at the beginning of the list',
      build: () {
        when(() => chatRepository.sendMessage('c1', 'new message'))
            .thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => const ChatState.messagesLoaded(
        conversationId: 'c1',
        messages: [message, message2],
      ),
      act: (cubit) => cubit.sendMessage('c1', 'new message'),
      expect: () => [
        predicate<ChatState>((s) {
          return s is ChatMessagesLoaded &&
              s.messages.length == 3 &&
              s.messages.first.isMe == true &&
              s.messages.first.text == 'new message' &&
              s.messages[1] == message &&
              s.messages[2] == message2;
        }),
      ],
    );
  });
}
