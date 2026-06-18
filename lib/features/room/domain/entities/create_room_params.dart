import 'package:bloot/features/room/domain/entities/room.dart';

/// Value object for creating a new room.
class CreateRoomParams {
  const CreateRoomParams({
    required this.name,
    required this.type,
    this.voiceEnabled = true,
    this.cameraEnabled = false,
    this.allowSpectators = true,
    this.gameSpeed = GameSpeed.normal,
  });

  final String name;
  final RoomType type;
  final bool voiceEnabled;
  final bool cameraEnabled;
  final bool allowSpectators;
  final GameSpeed gameSpeed;
}
