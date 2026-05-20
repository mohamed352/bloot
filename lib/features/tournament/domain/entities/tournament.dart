/// Domain entity representing a tournament.
class Tournament {
  const Tournament({
    required this.id,
    required this.name,
    required this.prize,
    required this.participants,
    required this.status,
    required this.date,
    this.isPremium = false,
    this.isJoined = false,
  });

  final String id;
  final String name;
  final String prize;
  final String participants;
  final String status;
  final String date;
  final bool isPremium;
  final bool isJoined;
}
