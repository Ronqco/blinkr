import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String categoryId;
  final String title;
  final String content;
  final List<String> imageUrls;
  final bool isNSFW;
  final String? nsfwWarning;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByMe;
  final DateTime createdAt;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.categoryId,
    required this.title,
    required this.content,
    this.imageUrls = const [],
    this.isNSFW = false,
    this.nsfwWarning,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLikedByMe = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        username,
        displayName,
        avatarUrl,
        categoryId,
        title,
        content,
        imageUrls,
        isNSFW,
        nsfwWarning,
        likesCount,
        commentsCount,
        isLikedByMe,
        createdAt,
      ];
}
