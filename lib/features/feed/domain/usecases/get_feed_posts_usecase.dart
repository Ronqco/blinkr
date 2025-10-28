import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/post_entity.dart';
import '../repositories/feed_repository.dart';

class GetFeedPostsUseCase {
  final FeedRepository repository;

  GetFeedPostsUseCase(this.repository);

  Future<Either<Failure, List<PostEntity>>> call({
    required String categoryId,
    int page = 0,
    int limit = 20,
  }) async {
    return await repository.getFeedPosts(
      categoryId: categoryId,
      page: page,
      limit: limit,
    );
  }
}
