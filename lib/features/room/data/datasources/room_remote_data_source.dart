import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import 'package:bloot/features/room/data/models/room_model.dart';

@lazySingleton
class RoomRemoteDataSource {
  Future<RoomModel> createRoom({
    required String name,
    required String type,
    required bool voiceEnabled,
    required bool cameraEnabled,
    required bool allowSpectators,
    required String gameSpeed,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return RoomModel(
      id: const Uuid().v4(),
      name: name,
      type: type,
      voiceEnabled: voiceEnabled,
      cameraEnabled: cameraEnabled,
      allowSpectators: allowSpectators,
      gameSpeed: gameSpeed,
      inviteCode: 'BLOOT-${DateTime.now().millisecond}',
      players: const [
        RoomPlayerModel(
          name: 'Ahmed',
          avatarUrl: 'https://i.pravatar.cc/150?img=11',
          isMe: true,
          level: 12,
        ),
      ],
    );
  }

  Future<RoomModel> getRoomById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return RoomModel(
      id: id,
      name: 'ahmeds_room',
      type: 'private',
      inviteCode: 'BLOOT-42',
      players: const [
        RoomPlayerModel(
          name: 'Ahmed',
          avatarUrl: 'https://i.pravatar.cc/150?img=11',
          isReady: true,
          isMe: true,
          level: 12,
        ),
        RoomPlayerModel(
          name: 'Khalid',
          avatarUrl: 'https://i.pravatar.cc/150?img=12',
          isReady: true,
          level: 8,
        ),
        RoomPlayerModel(
          name: 'Faisal',
          avatarUrl: 'https://i.pravatar.cc/150?img=33',
          isReady: true,
          team: 'B',
          level: 15,
        ),
        RoomPlayerModel(
          name: 'Omar',
          avatarUrl: 'https://i.pravatar.cc/150?img=44',
          isReady: true,
          team: 'B',
          level: 10,
        ),
      ],
      chatMessages: const [
        RoomChatMessageModel(user: 'Ahmed', text: 'welcome_everyone'),
        RoomChatMessageModel(user: 'System', text: 'khalid_joined_the_room'),
      ],
    );
  }

  Future<RoomModel> toggleReady(String roomId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final room = await getRoomById(roomId);
    final updatedPlayers = room.players.map((p) {
      if (p.isMe) return p.copyWith(isReady: !p.isReady);
      return p;
    }).toList();
    return room.copyWith(players: updatedPlayers);
  }

  Future<RoomModel> sendChatMessage(String roomId, String message) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final room = await getRoomById(roomId);
    final updatedMessages = [
      ...room.chatMessages,
      RoomChatMessageModel(user: 'Me', text: message),
    ];
    return room.copyWith(chatMessages: updatedMessages);
  }
}
