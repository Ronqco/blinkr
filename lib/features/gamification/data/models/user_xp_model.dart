import '../../domain/entities/user_xp_entity.dart';

class UserXpModel extends UserXpEntity {
  const UserXpModel({
    required super.userId,
    required super.categoryId,
    required super.xp,
    required super.level,
    required super.lastUpdated,
  });

  factory UserXpModel.fromJson(Map<String, dynamic> json) {
    return UserXpModel(
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String,
      xp: json['xp'] as int,
      level: json['level'] as int,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'xp': xp,
      'level': level,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}
