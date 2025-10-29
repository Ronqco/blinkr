import 'package:equatable/equatable.dart';

abstract class GamificationEvent extends Equatable {
  const GamificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserXp extends GamificationEvent {
  final String userId;

  const LoadUserXp(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadCategoryXp extends GamificationEvent {
  final String userId;
  final String categoryId;

  const LoadCategoryXp(this.userId, this.categoryId);

  @override
  List<Object?> get props => [userId, categoryId];
}

class AddXp extends GamificationEvent {
  final String userId;
  final String categoryId;
  final int xp;

  const AddXp(this.userId, this.categoryId, this.xp);

  @override
  List<Object?> get props => [userId, categoryId, xp];
}

class LoadAchievements extends GamificationEvent {
  final String userId;
  final String categoryId;

  const LoadAchievements(this.userId, this.categoryId);

  @override
  List<Object?> get props => [userId, categoryId];
}

class LoadLeaderboard extends GamificationEvent {
  final String categoryId;

  const LoadLeaderboard(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
