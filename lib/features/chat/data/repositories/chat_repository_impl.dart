import 'package:injectable/injectable.dart';

import 'package:bloot/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:bloot/features/chat/data/models/chat_model.dart';
import 'package:bloot/features/chat/domain/entities/chat.dart';
import 'package:bloot/features/chat/domain/entities/chat_user.dart';
import 'package:bloot/features/chat/domain/repositories/chat_repository.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({required ChatRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final ChatRemoteDataSource _remoteDataSource;

  @override
  Future<List<ChatConversation>> getConversations() async {
    final models = await _remoteDataSource.getConversations();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    return _remoteDataSource
        .watchMessages(conversationId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final models = await _remoteDataSource.getMessages(conversationId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> sendMessage(String conversationId, String message) async {
    await _remoteDataSource.sendMessage(conversationId, message);
  }

  @override
  Future<List<ChatUser>> searchUsers(String query) async {
    final models = await _remoteDataSource.searchUsers(query);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ChatConversation> createDirectConversation(String otherUserId) async {
    final model = await _remoteDataSource.createDirectConversation(otherUserId);
    return model.toEntity();
  }
}
