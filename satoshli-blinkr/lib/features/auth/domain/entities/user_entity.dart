import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final DateTime dateOfBirth;
  final String? gender;
  final bool showLocation;
  final bool showAge;
  final bool nsfwEnabled;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final List<String> interests;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    required this.dateOfBirth,
    this.gender,
    this.showLocation = true,
    this.showAge = true,
    this.nsfwEnabled = false,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.interests = const [],
    required this.createdAt,
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        displayName,
        bio,
        avatarUrl,
        dateOfBirth,
        gender,
        showLocation,
        showAge,
        nsfwEnabled,
        isPremium,
        premiumExpiresAt,
        interests,
        createdAt,
      ];
}
