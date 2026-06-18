import 'package:bloot/features/game/domain/entities/game.dart';

/// Repository contract for game operations.
abstract class GameRepository {
  /// Returns the game with the given [id].
  Future<Game> getGameById(String id);

  /// Watches the game in real-time.
  Stream<Game> watchGame(String id);

  /// Watches the game as a spectator (hands hidden).
  Stream<Game> watchGameAsSpectator(String id);

  /// Places a bid (sun, hokm, or pass).
  Future<void> placeBid(String gameId, String bid);

  /// Plays a card from the player's hand.
  Future<void> playCard(String gameId, String card);

  /// Claims bonuses (Hokm only).
  Future<void> claimBonuses(String gameId, List<Map<String, dynamic>> bonuses);

  /// Deals the next round after a completed round.
  Future<void> dealNextRound(String gameId);

  /// Resets a finished room to waiting state for a rematch.
  Future<void> rematch(String roomId);
}
