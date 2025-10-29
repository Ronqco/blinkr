// 📁 lib/features/feed/data/models/comment_model.dart
import '../../domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.userId,
    super.parentCommentId,
    required super.content,
    super.likesCount = 0,
    super.isActive = true,
    super.isReported = false,
    required super.createdAt,
    required super.updatedAt,
    super.username,
    super.avatarUrl,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      parentCommentId: json['parent_comment_id'] as String?,
      content: json['content'] as String,
      likesCount: json['likes_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      isReported: json['is_reported'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'parent_comment_id': parentCommentId,
      'content': content,
      'likes_count': likesCount,
      'is_active': isActive,
      'is_reported': isReported,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'username': username,
      'avatar_url': avatarUrl,
    };
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? parentCommentId,
    String? content,
    int? likesCount,
    bool? isActive,
    bool? isReported,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? username,
    String? avatarUrl,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      isActive: isActive ?? this.isActive,
      isReported: isReported ?? this.isReported,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
