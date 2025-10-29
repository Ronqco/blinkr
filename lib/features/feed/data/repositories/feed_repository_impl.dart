import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/post_entity.dart';
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
Future<Either<Failure, void>> sharePost(String postId) async {
  try {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      return const Left(ServerFailure('User not authenticated'));
    }

    await supabase.from('shares').upsert({
      'user_id': userId,
      'post_id': postId,
      'shared_at': DateTime.now().toIso8601String(),
    });

    return const Right(null);
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
  
  @override
  Future<Either<Failure, List<CompetitivePostEntity>>> getCompetitiveFeed({
    String? categoryId,
    int limit = 50,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      // Query rankings con posts
      var query = supabase
          .from('daily_feed_rankings')
          .select('''
            *,
            post:posts!inner(
              *,
              author:users!posts_user_id_fkey(id, username, display_name, avatar_url),
              category:interest_categories!posts_category_id_fkey(id, name, icon)
            )
          ''')
          .eq('date', DateTime.now().toIso8601String().split('T')[0]);

      // Filtrar por categoría si se especifica
      if (categoryId != null && categoryId != 'all') {
        query = query.eq('category_id', categoryId);
      }

      final response = await query
          .order('rank', ascending: true)
          .limit(limit);

      // Mapear a entidades
      final competitivePosts = (response as List<dynamic>).map((ranking) {
        final postData = ranking['post'];
        
        final post = PostEntity(
          id: postData['id'],
          userId: postData['author']['id'],
          username: postData['author']['username'],
          displayName: postData['author']['display_name'],
          avatarUrl: postData['author']['avatar_url'],
          categoryId: postData['category_id'],
          title: postData['title'],
          content: postData['content'],
          imageUrls: List<String>.from(postData['image_urls'] ?? []),
          isNSFW: postData['is_nsfw'] ?? false,
          nsfwWarning: postData['nsfw_warning'],
          likesCount: ranking['likes_count'] ?? 0,
          commentsCount: ranking['comments_count'] ?? 0,
          isLikedByMe: false, // TODO: Check user likes
          createdAt: DateTime.parse(postData['created_at']),
        );

        return CompetitivePostEntity(
          post: post,
          rank: ranking['rank'],
          finalScore: (ranking['final_score'] as num).toDouble(),
          sharesCount: ranking['shares_count'] ?? 0,
          rankingDate: DateTime.parse(ranking['date']),
        );
      }).toList();

      return Right(competitivePosts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Compartir post
  @override
  Future<Either<Failure, void>> sharePost(String postId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      await supabase.from('shares').insert({
        'user_id': userId,
        'post_id': postId,
      });

      return const Right(null);
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
