import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/nearby_user_entity.dart';

abstract class DiscoveryRepository {
  Future<Either<Failure, List<NearbyUserEntity>>> getNearbyUsers({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
    List<String>? filterByInterests,
  });

  Future<Either<Failure, void>> updateLocation({
    required double latitude,
    required double longitude,
  });
}
