// 📁 lib/features/feed/presentation/bloc/feed_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/competitive_post_entity.dart';

abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<PostEntity> posts;
  final bool hasMore;

  const FeedLoaded({
    required this.posts,
    this.hasMore = true,
  });

  @override
  List<Object> get props => [posts, hasMore];
}

class FeedCompetitiveLoaded extends FeedState {
  final List<CompetitivePostEntity> posts;

  const FeedCompetitiveLoaded(this.posts);

  @override
  List<Object> get props => [posts];
}

class FeedError extends FeedState {
  final String message;

  const FeedError(this.message);

  @override
  List<Object> get props => [message];
}