import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/chat/domain/repositories/chat_repository.dart';
import 'package:bloot/features/chat/presentation/cubit/new_message_state.dart';

@injectable
class NewMessageCubit extends Cubit<NewMessageState> {
  NewMessageCubit({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(const NewMessageState.initial());

  final ChatRepository _chatRepository;

  Future<void> search(String query) async {
    emit(const NewMessageState.loading());
    try {
      final users = await _chatRepository.searchUsers(query);
      emit(NewMessageState.loaded(users: users));
    } catch (e) {
      AppLogger.error('Failed to search users', error: e);
      emit(const NewMessageState.error(message: 'Failed to search users.'));
    }
  }

  Future<void> createConversation(String otherUserId) async {
    emit(const NewMessageState.creating());
    try {
      final conversation =
          await _chatRepository.createDirectConversation(otherUserId);
      emit(NewMessageState.conversationCreated(conversation: conversation));
    } catch (e) {
      AppLogger.error('Failed to create conversation', error: e);
      emit(
        const NewMessageState.error(message: 'Failed to start conversation.'),
      );
    }
  }
}
