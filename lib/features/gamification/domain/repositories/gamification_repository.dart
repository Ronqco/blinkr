import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_xp_entity.dart';
import '../entities/achievement_entity.dart';

abstract class GamificationRepository {
  Future<Either<Failure, List<UserXpEntity>>> getUserXp(String userId);
  Future<Either<Failure, UserXpEntity>> getCategoryXp(String userId, String categoryId);
  Future<Either<Failure, void>> addXp(String userId, String categoryId, int xp);
  Future<Either<Failure, List<AchievementEntity>>> getUserAchievements(String userId, String categoryId);
  Future<Either<Failure, List<UserXpEntity>>> getLeaderboard(String categoryId, {int limit = 50});
}
