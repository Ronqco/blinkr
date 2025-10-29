// 📁 lib/features/feed/domain/entities/comment_entity.dart
import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String? parentCommentId;
  final String content;
  final int likesCount;
  final bool isActive;
  final bool isReported;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? username;
  final String? avatarUrl;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentCommentId,
    required this.content,
    this.likesCount = 0,
    this.isActive = true,
    this.isReported = false,
    required this.createdAt,
    required this.updatedAt,
    this.username,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
        id,
        postId,
        userId,
        parentCommentId,
        content,
        likesCount,
        isActive,
        isReported,
        createdAt,
        updatedAt,
        username,
        avatarUrl,
      ];
}