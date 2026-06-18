/// Domain entity representing a single completed game in a user's history.
class GameHistory {
  const GameHistory({
    required this.id,
    required this.won,
    required this.score,
    required this.type,
    this.durationMinutes,
    this.playedAt,
  });

  final String id;
  final bool won;
  final String score;
  final String type;
  final int? durationMinutes;
  final DateTime? playedAt;
}
