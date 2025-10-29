import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recommendation_entity.dart';

abstract class RecommendationRepository {
  Future<Either<Failure, List<RecommendationEntity>>> getUserRecommendations();
  
  Future<Either<Failure, void>> updateUserInterestScore({
    required String interestId,
    required int likesCount,
  });
  
  Future<Either<Failure, List<RecommendationEntity>>> getTopRecommendations({
    int limit = 10,
  });
}
