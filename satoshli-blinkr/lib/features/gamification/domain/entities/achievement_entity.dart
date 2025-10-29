class AchievementEntity {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final String iconUrl;
  final int requiredXp;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementEntity({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.requiredXp,
    required this.isUnlocked,
    this.unlockedAt,
  });
}
