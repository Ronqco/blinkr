import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recommendation_entity.dart';
import '../repositories/recommendation_repository.dart';

class GetUserRecommendationsUseCase {
  final RecommendationRepository repository;

  GetUserRecommendationsUseCase(this.repository);

  Future<Either<Failure, List<RecommendationEntity>>> call() async {
    return await repository.getUserRecommendations();
  }
}
