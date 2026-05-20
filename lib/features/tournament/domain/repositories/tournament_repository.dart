import 'package:bloot/features/tournament/domain/entities/tournament.dart';

/// Repository contract for tournament operations.
abstract class TournamentRepository {
  /// Returns the list of all tournaments.
  Future<List<Tournament>> getTournaments();
}
