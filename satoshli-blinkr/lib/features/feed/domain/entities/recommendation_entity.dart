import 'package:equatable/equatable.dart';

class RecommendationEntity extends Equatable {
  final String interestId;
  final double score;
  final int likesCount;
  final int viewsCount;
  final DateTime lastUpdated;

  const RecommendationEntity({
    required this.interestId,
    required this.score,
    required this.likesCount,
    required this.viewsCount,
    required this.lastUpdated,
  });

  @override
  List<Object> get props => [
        interestId,
        score,
        likesCount,
        viewsCount,
        lastUpdated,
      ];
}
