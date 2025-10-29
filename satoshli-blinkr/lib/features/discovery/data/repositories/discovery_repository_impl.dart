import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/location/location_service.dart';
import '../../domain/entities/nearby_user_entity.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../datasources/discovery_remote_datasource.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final DiscoveryRemoteDataSource remoteDataSource;
  final LocationService locationService;

  DiscoveryRepositoryImpl(this.remoteDataSource, this.locationService);

  @override
  Future<Either<Failure, List<NearbyUserEntity>>> getNearbyUsers({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
    List<String>? filterByInterests,
  }) async {
    try {
      final users = await remoteDataSource.getNearbyUsers(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        filterByInterests: filterByInterests,
      );
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Add noise for privacy
      final position = await locationService.getCurrentLocation();
      if (position == null) {
        return const Left(ServerFailure('Could not get location'));
      }

      final noisyPosition = locationService.addLocationNoise(position);

      await remoteDataSource.updateLocation(
        userId: '', // Will be set from auth
        latitude: noisyPosition.latitude,
        longitude: noisyPosition.longitude,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
