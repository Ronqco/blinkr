import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_feed_posts_usecase.dart';
import '../../domain/repositories/feed_repository.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetFeedPostsUseCase getFeedPostsUseCase;
  final FeedRepository repository;

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
    // Mantener el estado actual mientras se crea el post
    final currentState = state;

    final result = await repository.createPost(
      categoryId: event.categoryId,
      title: event.title,
      content: event.content,
      imageUrls: event.imageUrls,
      isNSFW: event.isNSFW,
      nsfwWarning: event.nsfwWarning,
    );

    result.fold(
      (failure) {
        // Si falla, mostrar error pero mantener posts actuales
        if (currentState is FeedLoaded) {
          emit(currentState);
        }
        emit(FeedError(failure.message));
      },
      (newPost) {
        // Agregar el nuevo post al inicio de la lista
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
    // Hacer la llamada al backend
    final result = await repository.toggleLike(event.postId);

    result.fold(
      (failure) {
        // Si falla, mostrar error en snackbar (manejado en UI)
        // print('Error toggling like: ${failure.message}'); // ⚠️ Descomentado por script
      },
      (_) {
        // Éxito - no hacer nada, el UI se actualizará cuando recargue
        // La UI debería mostrar feedback visual inmediato
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
        // print('Error sharing post: ${failure.message}'); // ⚠️ Descomentado por script
      },
      (_) {
        // Éxito - el share se registró
      },
    );
  }

}