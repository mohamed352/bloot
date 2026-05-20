/// Base exception for game-related failures.
class GameException implements Exception {
  const GameException(this.message);

  final String message;
}
