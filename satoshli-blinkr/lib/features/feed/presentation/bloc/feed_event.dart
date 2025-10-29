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

class FeedLoadCompetitive extends FeedEvent {
  final String? categoryId;

  const FeedLoadCompetitive({this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class FeedToggleLike extends FeedEvent {
  final String postId;

  const FeedToggleLike(this.postId);

  @override
  List<Object> get props => [postId];
}

class FeedSharePost extends FeedEvent {
  final String postId;

  const FeedSharePost(this.postId);

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
  final String? postType;

  const FeedCreatePost({
    required this.categoryId,
    required this.title,
    required this.content,
    this.imageUrls,
    this.isNSFW = false,
    this.nsfwWarning,
    this.postType = 'post',
  });

  @override
  List<Object?> get props => [
        categoryId,
        title,
        content,
        imageUrls,
        isNSFW,
        nsfwWarning,
        postType,
      ];
}

class FeedRefresh extends FeedEvent {
  final String categoryId;

  const FeedRefresh(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class FeedFilterByType extends FeedEvent {
  final String postType;

  const FeedFilterByType(this.postType);

  @override
  List<Object> get props => [postType];
}

class FeedChangeSortBy extends FeedEvent {
  final String sortBy;

  const FeedChangeSortBy(this.sortBy);

  @override
  List<Object> get props => [sortBy];
}
