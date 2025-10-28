import 'package:equatable/equatable.dart';

class NearbyUserEntity extends Equatable {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final int age;
  final double distanceKm;
  final List<String> interests;
  final List<String> commonInterests;
  final bool isPremium;
  final DateTime lastSeenAt;

  const NearbyUserEntity({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    required this.age,
    required this.distanceKm,
    required this.interests,
    required this.commonInterests,
    this.isPremium = false,
    required this.lastSeenAt,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        displayName,
        avatarUrl,
        bio,
        age,
        distanceKm,
        interests,
        commonInterests,
        isPremium,
        lastSeenAt,
      ];
}
