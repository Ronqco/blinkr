import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_xp_entity.dart';
import '../repositories/gamification_repository.dart';

class GetUserXpUseCase {
  final GamificationRepository repository;

  GetUserXpUseCase(this.repository);

  Future<Either<Failure, List<UserXpEntity>>> call(String userId) async {
    return await repository.getUserXp(userId);
  }
}
