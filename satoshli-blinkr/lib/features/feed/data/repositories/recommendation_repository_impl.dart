import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/recommendation_entity.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../models/recommendation_model.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final SupabaseClient supabase;

  RecommendationRepositoryImpl(this.supabase);

  @override
  Future<Either<Failure, List<RecommendationEntity>>> getUserRecommendations() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      final response = await supabase
          .from('user_interest_scores_v2')
          .select()
          .eq('user_id', userId)
          .order('score', ascending: false)
          .limit(20);

      final recommendations = (response as List<dynamic>)
          .map((json) => RecommendationModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(recommendations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserInterestScore({
    required String interestId,
    required int likesCount,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      final score = likesCount * 1.5;

      await supabase.from('user_interest_scores_v2').upsert({
        'user_id': userId,
        'interest_id': interestId,
        'score': score,
        'likes_count': likesCount,
        'last_updated': DateTime.now().toIso8601String(),
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RecommendationEntity>>> getTopRecommendations({
    int limit = 10,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      final response = await supabase
          .from('user_interest_scores_v2')
          .select()
          .eq('user_id', userId)
          .order('score', ascending: false)
          .limit(limit);

      final recommendations = (response as List<dynamic>)
          .map((json) => RecommendationModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(recommendations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
