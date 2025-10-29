import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/nearby_user_entity.dart';
import '../repositories/discovery_repository.dart';

class GetNearbyUsersUseCase {
  final DiscoveryRepository repository;

  GetNearbyUsersUseCase(this.repository);

  Future<Either<Failure, List<NearbyUserEntity>>> call({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
    List<String>? filterByInterests,
  }) async {
    return await repository.getNearbyUsers(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      filterByInterests: filterByInterests,
    );
  }
}
