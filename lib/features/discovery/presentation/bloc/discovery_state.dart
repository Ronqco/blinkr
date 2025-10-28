import 'package:equatable/equatable.dart';
import '../../domain/entities/nearby_user_entity.dart';

abstract class DiscoveryState extends Equatable {
  const DiscoveryState();

  @override
  List<Object?> get props => [];
}

class DiscoveryInitial extends DiscoveryState {}

class DiscoveryLoading extends DiscoveryState {}

class DiscoveryLoaded extends DiscoveryState {
  final List<NearbyUserEntity> users;

  const DiscoveryLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class DiscoveryError extends DiscoveryState {
  final String message;

  const DiscoveryError(this.message);

  @override
  List<Object> get props => [message];
}
