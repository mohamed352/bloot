import 'package:injectable/injectable.dart';

import 'package:bloot/features/chat/data/models/chat_model.dart';

@lazySingleton
class ChatRemoteDataSource {
  Future<List<ChatConversationModel>> getConversations() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return [
      const ChatConversationModel(
        id: 'chat_0',
        name: 'Khalid Al-Rashid',
        avatarUrl: 'https://i.pravatar.cc/150?img=12',
        lastMessage: 'good_game_yesterday',
        time: '2m',
        unread: 2,
        type: 'direct',
      ),
      const ChatConversationModel(
        id: 'chat_1',
        name: 'Room: Weekend Bash',
        lastMessage: 'ahmed_im_ready_when_you_are',
        time: '15m',
        type: 'rooms',
      ),
      const ChatConversationModel(
        id: 'chat_2',
        name: 'Faisal Band',
        avatarUrl: 'https://i.pravatar.cc/150?img=33',
        lastMessage: 'lets_play_again_tonight',
        time: '1h',
        unread: 1,
        type: 'direct',
      ),
      const ChatConversationModel(
        id: 'chat_3',
        name: 'Tournament: Gulf Cup',
        lastMessage: 'registration_closes_in_2_hours',
        time: '3h',
        type: 'tournaments',
      ),
      const ChatConversationModel(
        id: 'chat_4',
        name: 'Omar Hassan',
        avatarUrl: 'https://i.pravatar.cc/150?img=44',
        lastMessage: 'sent_a_room_invitation',
        time: '1d',
        type: 'direct',
      ),
    ];
  }

  Future<List<ChatMessageModel>> getMessages(String conversationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const [
      ChatMessageModel(
        id: 'msg_0',
        text: 'hey_want_to_play_tonight',
        time: '10:30 AM',
      ),
      ChatMessageModel(
        id: 'msg_1',
        text: 'sure_what_time',
        isMe: true,
        time: '10:32 AM',
      ),
      ChatMessageModel(id: 'msg_2', text: 'around_8_pm', time: '10:33 AM'),
      ChatMessageModel(
        id: 'msg_3',
        text: 'perfect_ill_create_a_room',
        isMe: true,
        time: '10:35 AM',
      ),
      ChatMessageModel(
        id: 'msg_4',
        text: 'good_game_yesterday',
        time: '9:00 AM',
      ),
      ChatMessageModel(
        id: 'msg_5',
        text: '',
        isMe: true,
        time: '10:36 AM',
        type: 'image',
        imageUrl:
            'https://images.unsplash.com/photo-1541963463532-d68292c34b19?w=400&q=80',
      ),
    ];
  }

  Future<List<ChatMessageModel>> sendMessage(
    String conversationId,
    String message,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final messages = await getMessages(conversationId);
    return [
      ...messages,
      ChatMessageModel(id: 'msg_new', text: message, isMe: true, time: 'now'),
    ];
  }
}
