import 'package:bloot/features/game/domain/entities/game.dart';

/// Repository contract for game operations.
abstract class GameRepository {
  /// Returns the game with the given [id].
  Future<Game> getGameById(String id);
}
