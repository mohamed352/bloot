/// Domain entity representing a user achievement / badge.
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    this.description,
    this.iconName,
    this.unlockedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String? iconName;
  final DateTime? unlockedAt;

  bool get earned => unlockedAt != null;
}
