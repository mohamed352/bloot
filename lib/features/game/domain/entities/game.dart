/// Domain entity representing a game player.
class GamePlayer {
  const GamePlayer({
    required this.name,
    required this.avatarUrl,
    required this.team,
    this.isActive = false,
    this.isMuted = false,
    this.hasCamera = true,
    this.isTop = false,
  });

  final String name;
  final String avatarUrl;
  final String team;
  final bool isActive;
  final bool isMuted;
  final bool hasCamera;
  final bool isTop;
}

/// Domain entity representing a game session.
class Game {
  const Game({
    required this.id,
    required this.players,
    required this.myHand,
    required this.playedCards,
    required this.scoreUs,
    required this.scoreThem,
    required this.trump,
  });

  final String id;
  final List<GamePlayer> players;
  final List<String> myHand;
  final List<String> playedCards;
  final int scoreUs;
  final int scoreThem;
  final String trump;
}
