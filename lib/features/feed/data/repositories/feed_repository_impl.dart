import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource remoteDataSource;
  final SupabaseClient supabase;

  FeedRepositoryImpl(this.remoteDataSource, this.supabase);

  @override
  Future<Either<Failure, List<PostEntity>>> getFeedPosts({
    required String categoryId,
    int page = 0,
    int limit = 20,
  }) async {
    try {
      final posts = await remoteDataSource.getFeedPosts(
        categoryId: categoryId,
        page: page,
        limit: limit,
      );
      return Right(posts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> createPost({
    required String categoryId,
    required String title,
    required String content,
    List<String>? imageUrls,
    bool isNSFW = false,
    String? nsfwWarning,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      final post = await remoteDataSource.createPost(
        userId: userId,
        categoryId: categoryId,
        title: title,
        content: content,
        imageUrls: imageUrls,
        isNSFW: isNSFW,
        nsfwWarning: nsfwWarning,
      );
      return Right(post);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      await remoteDataSource.deletePost(postId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleLike(String postId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      await remoteDataSource.toggleLike(userId, postId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getComments(String postId) async {
    try {
      final comments = await remoteDataSource.getComments(postId);
      return Right(comments);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> createComment({
    required String postId,
    required String content,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      final comment = await remoteDataSource.createComment(
        userId: userId,
        postId: postId,
        content: content,
      );
      return Right(comment);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      await remoteDataSource.deleteComment(commentId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reportPost({
    required String postId,
    required String reason,
    String? description,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      await remoteDataSource.reportPost(
        reporterId: userId,
        postId: postId,
        reason: reason,
        description: description,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
