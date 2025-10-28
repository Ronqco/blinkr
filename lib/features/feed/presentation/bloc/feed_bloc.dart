import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_feed_posts_usecase.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetFeedPostsUseCase getFeedPostsUseCase;

  FeedBloc({required this.getFeedPostsUseCase}) : super(FeedInitial()) {
    on<FeedLoadPosts>(_onLoadPosts);
    on<FeedRefresh>(_onRefresh);
  }

  Future<void> _onLoadPosts(
    FeedLoadPosts event,
    Emitter<FeedState> emit,
  ) async {
    if (event.page == 0) {
      emit(FeedLoading());
    }

    final result = await getFeedPostsUseCase(
      categoryId: event.categoryId,
      page: event.page,
    );

    result.fold(
      (failure) => emit(FeedError(failure.message)),
      (posts) {
        if (state is FeedLoaded && event.page > 0) {
          final currentPosts = (state as FeedLoaded).posts;
          emit(FeedLoaded(
            posts: [...currentPosts, ...posts],
            hasMore: posts.isNotEmpty,
          ));
        } else {
          emit(FeedLoaded(posts: posts, hasMore: posts.isNotEmpty));
        }
      },
    );
  }

  Future<void> _onRefresh(
    FeedRefresh event,
    Emitter<FeedState> emit,
  ) async {
    add(FeedLoadPosts(categoryId: event.categoryId, page: 0));
  }
}
