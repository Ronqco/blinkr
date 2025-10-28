import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String content;
  final int likesCount;
  final bool isLikedByMe;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.content,
    this.likesCount = 0,
    this.isLikedByMe = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        postId,
        userId,
        username,
        displayName,
        avatarUrl,
        content,
        likesCount,
        isLikedByMe,
        createdAt,
      ];
}
