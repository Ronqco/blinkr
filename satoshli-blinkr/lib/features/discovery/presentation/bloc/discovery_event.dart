import 'package:equatable/equatable.dart';

abstract class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();

  @override
  List<Object?> get props => [];
}

class DiscoveryLoadNearbyUsers extends DiscoveryEvent {
  final double? radiusKm;
  final List<String>? filterByInterests;

  const DiscoveryLoadNearbyUsers({
    this.radiusKm,
    this.filterByInterests,
  });

  @override
  List<Object?> get props => [radiusKm, filterByInterests];
}

class DiscoveryUpdateLocation extends DiscoveryEvent {}

class DiscoveryRefresh extends DiscoveryEvent {}
