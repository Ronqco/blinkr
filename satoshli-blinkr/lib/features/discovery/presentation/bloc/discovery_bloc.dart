import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/utils/rate_limiter.dart'; // ✅ AÑADIR
import '../../domain/usecases/get_nearby_users_usecase.dart';
import 'discovery_event.dart';
import 'discovery_state.dart';

class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final GetNearbyUsersUseCase getNearbyUsersUseCase;
  final LocationService _locationService = LocationService();
  final _rateLimiter = RateLimiter(cooldown: const Duration(seconds: 5)); // ✅ CORRECTO

  DiscoveryBloc({required this.getNearbyUsersUseCase})
      : super(DiscoveryInitial()) {
    on<DiscoveryLoadNearbyUsers>(_onLoadNearbyUsers);
    on<DiscoveryRefresh>(_onRefresh);
  }

  Future<void> _onLoadNearbyUsers(
    DiscoveryLoadNearbyUsers event,
    Emitter<DiscoveryState> emit,
  ) async {
    // ✅ Usar rate limiter
    if (!_rateLimiter.canExecute('load_nearby')) {
      final waitTime = _rateLimiter.timeUntilNextCall('load_nearby');
      emit(DiscoveryError('Espera ${waitTime.inSeconds}s antes de buscar'));
      return;
    }

    emit(DiscoveryLoading());

    final position = await _locationService.getCurrentLocation();
    if (position == null) {
      emit(const DiscoveryError('No se pudo obtener la ubicación'));
      return;
    }

    final result = await getNearbyUsersUseCase(
      latitude: position.latitude,
      longitude: position.longitude,
      radiusKm: event.radiusKm ?? 50.0,
      filterByInterests: event.filterByInterests,
    );

    result.fold(
      (failure) => emit(DiscoveryError(failure.message)),
      (users) => emit(DiscoveryLoaded(users)),
    );
  }

  Future<void> _onRefresh(
    DiscoveryRefresh event,
    Emitter<DiscoveryState> emit,
  ) async {
    add(const DiscoveryLoadNearbyUsers());
  }
}
