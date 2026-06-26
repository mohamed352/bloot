/// Base exception for room-related failures.
class RoomException implements Exception {
  const RoomException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'RoomException($code): $message';
}

class RoomFullException extends RoomException {
  const RoomFullException() : super('Room is full', code: 'ROOM_FULL');
}

class RoomNotFoundException extends RoomException {
  const RoomNotFoundException()
    : super('Room not found', code: 'ROOM_NOT_FOUND');
}

class AlreadyInRoomException extends RoomException {
  const AlreadyInRoomException()
    : super('You are already in this room', code: 'ALREADY_IN_ROOM');
}

class PlayerNotInRoomException extends RoomException {
  const PlayerNotInRoomException()
    : super('Player not in room', code: 'PLAYER_NOT_IN_ROOM');
}

class UnauthenticatedException extends RoomException {
  const UnauthenticatedException()
    : super('User not authenticated', code: 'UNAUTHENTICATED');
}

class WrongPasswordException extends RoomException {
  const WrongPasswordException()
    : super('Incorrect room password', code: 'WRONG_PASSWORD');
}
