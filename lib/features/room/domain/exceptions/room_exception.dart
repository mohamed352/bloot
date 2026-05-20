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
