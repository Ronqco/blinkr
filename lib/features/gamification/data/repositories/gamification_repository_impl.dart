import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_xp_entity.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../datasources/gamification_remote_datasource.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  final GamificationRemoteDataSource remoteDataSource;

  GamificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<UserXpEntity>>> getUserXp(String userId) async {
    try {
      final result = await remoteDataSource.getUserXp(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserXpEntity>> getCategoryXp(String userId, String categoryId) async {
    try {
      final result = await remoteDataSource.getCategoryXp(userId, categoryId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addXp(String userId, String categoryId, int xp) async {
    try {
      await remoteDataSource.addXp(userId, categoryId, xp);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AchievementEntity>>> getUserAchievements(String userId, String categoryId) async {
    try {
      final result = await remoteDataSource.getUserAchievements(userId, categoryId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserXpEntity>>> getLeaderboard(String categoryId, {int limit = 50}) async {
    try {
      final result = await remoteDataSource.getLeaderboard(categoryId, limit: limit);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
