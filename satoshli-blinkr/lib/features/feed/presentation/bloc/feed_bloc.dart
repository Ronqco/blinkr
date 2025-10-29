import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_feed_posts_usecase.dart';
import '../../domain/repositories/feed_repository.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetFeedPostsUseCase getFeedPostsUseCase;
  final FeedRepository repository;
  
  String _currentPostType = 'all';
  String _currentSortBy = 'recommended';

  FeedBloc({
    required this.getFeedPostsUseCase,
    required this.repository,
  }) : super(FeedInitial()) {
    on<FeedLoadPosts>(_onLoadPosts);
    on<FeedLoadCompetitive>(_onLoadCompetitive);
    on<FeedRefresh>(_onRefresh);
    on<FeedCreatePost>(_onCreatePost);
    on<FeedToggleLike>(_onToggleLike);
    on<FeedSharePost>(_onSharePost);
    on<FeedFilterByType>(_onFilterByType);
    on<FeedChangeSortBy>(_onChangeSortBy);
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
      postType: _currentPostType,
      sortBy: _currentSortBy,
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

  Future<void> _onLoadCompetitive(
    FeedLoadCompetitive event,
    Emitter<FeedState> emit,
  ) async {
    emit(FeedLoading());

    final result = await repository.getCompetitiveFeed(
      categoryId: event.categoryId,
    );

    result.fold(
      (failure) => emit(FeedError(failure.message)),
      (posts) => emit(FeedCompetitiveLoaded(posts)),
    );
  }

  Future<void> _onRefresh(
    FeedRefresh event,
    Emitter<FeedState> emit,
  ) async {
    add(FeedLoadPosts(categoryId: event.categoryId, page: 0));
  }

  Future<void> _onCreatePost(
    FeedCreatePost event,
    Emitter<FeedState> emit,
  ) async {
    final currentState = state;

    final result = await repository.createPost(
      categoryId: event.categoryId,
      title: event.title,
      content: event.content,
      imageUrls: event.imageUrls,
      isNSFW: event.isNSFW,
      nsfwWarning: event.nsfwWarning,
      postType: event.postType ?? 'post',
    );

    result.fold(
      (failure) {
        if (currentState is FeedLoaded) {
          emit(currentState);
        }
        emit(FeedError(failure.message));
      },
      (newPost) {
        if (currentState is FeedLoaded) {
          emit(FeedLoaded(
            posts: [newPost, ...currentState.posts],
            hasMore: currentState.hasMore,
          ));
        } else {
          emit(FeedLoaded(posts: [newPost], hasMore: true));
        }
      },
    );
  }

  Future<void> _onToggleLike(
    FeedToggleLike event,
    Emitter<FeedState> emit,
  ) async {
    final result = await repository.toggleLike(event.postId);

    result.fold(
      (failure) {
        // Error handling
      },
      (_) {
        // Actualizar puntuación de intereses basado en like
        _updateUserInterestScore(event.postId);
      },
    );
  }

  Future<void> _onSharePost(
    FeedSharePost event,
    Emitter<FeedState> emit,
  ) async {
    final result = await repository.sharePost(event.postId);

    result.fold(
      (failure) {
        // Error handling
      },
      (_) {
        // Share registrado
      },
    );
  }

  Future<void> _onFilterByType(
    FeedFilterByType event,
    Emitter<FeedState> emit,
  ) async {
    _currentPostType = event.postType;
    final currentState = state;
    if (currentState is FeedLoaded) {
      add(FeedLoadPosts(categoryId: currentState.categoryId, page: 0));
    }
  }

  Future<void> _onChangeSortBy(
    FeedChangeSortBy event,
    Emitter<FeedState> emit,
  ) async {
    _currentSortBy = event.sortBy;
    final currentState = state;
    if (currentState is FeedLoaded) {
      add(FeedLoadPosts(categoryId: currentState.categoryId, page: 0));
    }
  }

  Future<void> _updateUserInterestScore(String postId) async {
    // Obtener categoría del post
    // Actualizar puntuación del usuario para esa categoría
    // Esto alimenta el algoritmo de recomendación
  }
}
