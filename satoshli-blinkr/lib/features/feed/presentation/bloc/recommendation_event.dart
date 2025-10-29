import 'package:equatable/equatable.dart';

abstract class RecommendationEvent extends Equatable {
  const RecommendationEvent();

  @override
  List<Object?> get props => [];
}

class RecommendationLoadRecommendations extends RecommendationEvent {
  const RecommendationLoadRecommendations();
}

class RecommendationUpdateScore extends RecommendationEvent {
  final String interestId;
  final int likesCount;

  const RecommendationUpdateScore({
    required this.interestId,
    required this.likesCount,
  });

  @override
  List<Object> get props => [interestId, likesCount];
}
