import '../../domain/entities/recommendation_entity.dart';

class RecommendationModel extends RecommendationEntity {
  const RecommendationModel({
    required super.interestId,
    required super.score,
    required super.likesCount,
    required super.viewsCount,
    required super.lastUpdated,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      interestId: json['interest_id'] as String,
      score: (json['score'] as num).toDouble(),
      likesCount: json['likes_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interest_id': interestId,
      'score': score,
      'likes_count': likesCount,
      'views_count': viewsCount,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}
