import '../../domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.userId,
    required super.username,
    required super.displayName,
    super.avatarUrl,
    required super.categoryId,
    super.postType = 'post',
    required super.title,
    required super.content,
    super.imageUrls,
    super.isNSFW,
    super.nsfwWarning,
    super.likesCount,
    super.commentsCount,
    super.isLikedByMe,
    required super.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      categoryId: json['category_id'] as String,
      postType: json['post_type'] as String? ?? 'post',
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isNSFW: json['is_nsfw'] as bool? ?? false,
      nsfwWarning: json['nsfw_warning'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'category_id': categoryId,
      'post_type': postType,
      'title': title,
      'content': content,
      'image_urls': imageUrls,
      'is_nsfw': isNSFW,
      'nsfw_warning': nsfwWarning,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked_by_me': isLikedByMe,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
