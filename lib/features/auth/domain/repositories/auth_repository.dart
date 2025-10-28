import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String username,
    required String displayName,
    required DateTime dateOfBirth,
    String? gender,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
    bool? showLocation,
    bool? showAge,
    bool? nsfwEnabled,
  });

  Future<Either<Failure, void>> updateInterests(List<String> interests);

  Stream<UserEntity?> get authStateChanges;
}
