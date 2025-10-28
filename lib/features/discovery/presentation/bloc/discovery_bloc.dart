import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/location/location_service.dart';
import '../../domain/usecases/get_nearby_users_usecase.dart';
import 'discovery_event.dart';
import 'discovery_state.dart';

class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final GetNearbyUsersUseCase getNearbyUsersUseCase;
  final LocationService _locationService = LocationService();

  DiscoveryBloc({required this.getNearbyUsersUseCase})
      : super(DiscoveryInitial()) {
    on<DiscoveryLoadNearbyUsers>(_onLoadNearbyUsers);
    on<DiscoveryRefresh>(_onRefresh);
  }

  Future<void> _onLoadNearbyUsers(
    DiscoveryLoadNearbyUsers event,
    Emitter<DiscoveryState> emit,
  ) async {
    emit(DiscoveryLoading());

    // Get current location
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
