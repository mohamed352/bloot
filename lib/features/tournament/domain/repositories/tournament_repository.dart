import 'package:bloot/features/tournament/domain/entities/tournament.dart';

/// Repository contract for tournament operations.
abstract class TournamentRepository {
  /// Returns all tournaments.
  Future<List<Tournament>> getTournaments();

  /// Returns a single tournament by [id].
  Future<Tournament?> getTournamentById(String id);

  /// Watches a tournament in real-time.
  Stream<Tournament> watchTournament(String id);

  /// Adds the current user to [tournamentId].
  Future<Tournament> joinTournament(String tournamentId);
}
