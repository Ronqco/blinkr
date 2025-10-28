import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.username,
    required super.displayName,
    super.bio,
    super.avatarUrl,
    required super.dateOfBirth,
    super.gender,
    super.showLocation,
    super.showAge,
    super.nsfwEnabled,
    super.isPremium,
    super.premiumExpiresAt,
    super.interests,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      gender: json['gender'] as String?,
      showLocation: json['show_location'] as bool? ?? true,
      showAge: json['show_age'] as bool? ?? true,
      nsfwEnabled: json['nsfw_enabled'] as bool? ?? false,
      isPremium: json['is_premium'] as bool? ?? false,
      premiumExpiresAt: json['premium_expires_at'] != null
          ? DateTime.parse(json['premium_expires_at'] as String)
          : null,
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'display_name': displayName,
      'bio': bio,
      'avatar_url': avatarUrl,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'show_location': showLocation,
      'show_age': showAge,
      'nsfw_enabled': nsfwEnabled,
      'is_premium': isPremium,
      'premium_expires_at': premiumExpiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
