// 📁 lib/features/feed/domain/repositories/feed_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/post_entity.dart';
import '../entities/comment_entity.dart';
import '../entities/competitive_post_entity.dart';

abstract class FeedRepository {
  Future<Either<Failure, List<PostEntity>>> getFeedPosts({
    required String categoryId,
    int page = 0,
    int limit = 20,
  });

  Future<Either<Failure, PostEntity>> createPost({
    required String categoryId,
    required String title,
    required String content,
    List<String>? imageUrls,
    bool isNSFW = false,
    String? nsfwWarning,
  });

  Future<Either<Failure, void>> deletePost(String postId);

  Future<Either<Failure, void>> toggleLike(String postId);

  Future<Either<Failure, List<CommentEntity>>> getComments(String postId);

  Future<Either<Failure, CommentEntity>> createComment({
    required String postId,
    required String content,
  });

  Future<Either<Failure, void>> deleteComment(String commentId);
  
  Future<Either<Failure, List<CompetitivePostEntity>>> getCompetitiveFeed({
    String? categoryId,
    int limit = 50,
  });

  Future<Either<Failure, void>> sharePost(String postId);

  Future<Either<Failure, void>> reportPost({
    required String postId,
    required String reason,
    String? description,
  });
}
