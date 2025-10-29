class UserXpEntity {
  final String userId;
  final String categoryId;
  final int xp;
  final int level;
  final DateTime lastUpdated;

  const UserXpEntity({
    required this.userId,
    required this.categoryId,
    required this.xp,
    required this.level,
    required this.lastUpdated,
  });

  int get xpForNextLevel {
    // XP required for next level: level * 100
    return (level + 1) * 100;
  }

  int get xpProgress {
    // Current progress within this level
    final xpForCurrentLevel = level * 100;
    return xp - xpForCurrentLevel;
  }

  double get progressPercentage {
    return xpProgress / xpForNextLevel;
  }
}
