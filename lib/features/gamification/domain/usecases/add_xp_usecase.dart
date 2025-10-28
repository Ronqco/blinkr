import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/gamification_repository.dart';

class AddXpUseCase {
  final GamificationRepository repository;

  AddXpUseCase(this.repository);

  Future<Either<Failure, void>> call(String userId, String categoryId, int xp) async {
    return await repository.addXp(userId, categoryId, xp);
  }
}
