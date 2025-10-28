import 'package:equatable/equatable.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class FeedLoadPosts extends FeedEvent {
  final String categoryId;
  final int page;

  const FeedLoadPosts({
    required this.categoryId,
    this.page = 0,
  });

  @override
  List<Object> get props => [categoryId, page];
}

class FeedToggleLike extends FeedEvent {
  final String postId;

  const FeedToggleLike(this.postId);

  @override
  List<Object> get props => [postId];
}

class FeedCreatePost extends FeedEvent {
  final String categoryId;
  final String title;
  final String content;
  final List<String>? imageUrls;
  final bool isNSFW;
  final String? nsfwWarning;

  const FeedCreatePost({
    required this.categoryId,
    required this.title,
    required this.content,
    this.imageUrls,
    this.isNSFW = false,
    this.nsfwWarning,
  });

  @override
  List<Object?> get props => [
        categoryId,
        title,
        content,
        imageUrls,
        isNSFW,
        nsfwWarning,
      ];
}

class FeedRefresh extends FeedEvent {
  final String categoryId;

  const FeedRefresh(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}
