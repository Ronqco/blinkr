import 'package:equatable/equatable.dart';
import '../../domain/entities/recommendation_entity.dart';

abstract class RecommendationState extends Equatable {
  const RecommendationState();

  @override
  List<Object?> get props => [];
}

class RecommendationInitial extends RecommendationState {}

class RecommendationLoading extends RecommendationState {}

class RecommendationLoaded extends RecommendationState {
  final List<RecommendationEntity> recommendations;

  const RecommendationLoaded(this.recommendations);

  @override
  List<Object> get props => [recommendations];
}

class RecommendationError extends RecommendationState {
  final String message;

  const RecommendationError(this.message);

  @override
  List<Object> get props => [message];
}
