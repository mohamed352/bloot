/// Base exception for tournament-related failures.
class TournamentException implements Exception {
  const TournamentException(this.message);

  final String message;
}
