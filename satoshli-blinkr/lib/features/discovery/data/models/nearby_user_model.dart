import '../../domain/entities/nearby_user_entity.dart';

class NearbyUserModel extends NearbyUserEntity {
  const NearbyUserModel({
    required super.id,
    required super.username,
    required super.displayName,
    super.avatarUrl,
    super.bio,
    required super.age,
    required super.distanceKm,
    required super.interests,
    required super.commonInterests,
    super.isPremium,
    required super.lastSeenAt,
  });

  factory NearbyUserModel.fromJson(Map<String, dynamic> json) {
    return NearbyUserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      age: json['age'] as int,
      distanceKm: (json['distance_km'] as num).toDouble(),
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      commonInterests: (json['common_interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isPremium: json['is_premium'] as bool? ?? false,
      lastSeenAt: DateTime.parse(json['last_seen_at'] as String),
    );
  }
}
