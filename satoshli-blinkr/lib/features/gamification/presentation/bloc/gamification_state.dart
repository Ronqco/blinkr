import 'package:equatable/equatable.dart';
import '../../domain/entities/user_xp_entity.dart';
import '../../domain/entities/achievement_entity.dart';

abstract class GamificationState extends Equatable {
  const GamificationState();

  @override
  List<Object?> get props => [];
}

class GamificationInitial extends GamificationState {}

class GamificationLoading extends GamificationState {}

class UserXpLoaded extends GamificationState {
  final List<UserXpEntity> userXp;

  const UserXpLoaded(this.userXp);

  @override
  List<Object?> get props => [userXp];
}

class CategoryXpLoaded extends GamificationState {
  final UserXpEntity categoryXp;

  const CategoryXpLoaded(this.categoryXp);

  @override
  List<Object?> get props => [categoryXp];
}

class XpAdded extends GamificationState {
  final String message;

  const XpAdded(this.message);

  @override
  List<Object?> get props => [message];
}

class AchievementsLoaded extends GamificationState {
  final List<AchievementEntity> achievements;

  const AchievementsLoaded(this.achievements);

  @override
  List<Object?> get props => [achievements];
}

class LeaderboardLoaded extends GamificationState {
  final List<UserXpEntity> leaderboard;

  const LeaderboardLoaded(this.leaderboard);

  @override
  List<Object?> get props => [leaderboard];
}

class GamificationError extends GamificationState {
  final String message;

  const GamificationError(this.message);

  @override
  List<Object?> get props => [message];
}
