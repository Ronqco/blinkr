import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String username,
    required String displayName,
    required DateTime dateOfBirth,
    String? gender,
  }) async {
    return await repository.signUp(
      email: email,
      password: password,
      username: username,
      displayName: displayName,
      dateOfBirth: dateOfBirth,
      gender: gender,
    );
  }
}
