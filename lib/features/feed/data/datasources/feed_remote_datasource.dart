import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

abstract class FeedRemoteDataSource {
  Future<List<PostModel>> getFeedPosts({
    required String categoryId,
    int page = 0,
    int limit = 20,
  });

  Future<PostModel> createPost({
    required String userId,
    required String categoryId,
    required String title,
    required String content,
    List<String>? imageUrls,
    bool isNSFW = false,
    String? nsfwWarning,
  });

  Future<void> deletePost(String postId);

  Future<void> toggleLike(String userId, String postId);

  Future<List<CommentModel>> getComments(String postId);

  Future<CommentModel> createComment({
    required String userId,
    required String postId,
    required String content,
  });

  Future<void> deleteComment(String commentId);

  Future<void> reportPost({
    required String reporterId,
    required String postId,
    required String reason,
    String? description,
  });
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final SupabaseClient supabase;

  FeedRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<PostModel>> getFeedPosts({
    required String categoryId,
    int page = 0,
    int limit = 20,
  }) async {
    final currentUserId = supabase.auth.currentUser?.id;

    final response = await supabase
        .from('posts')
        .select('''
          *,
          users!inner(username, display_name, avatar_url)
        ''')
        .eq('category_id', categoryId)
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .range(page * limit, (page + 1) * limit - 1);

    final posts = await Future.wait(
      (response as List<dynamic>).map((postData) async {
        // Check if user liked this post
        bool isLikedByMe = false;
        if (currentUserId != null) {
          final likeCheck = await supabase
              .from('likes')
              .select()
              .eq('user_id', currentUserId)
              .eq('post_id', postData['id'])
              .maybeSingle();
          isLikedByMe = likeCheck != null;
        }

        return PostModel.fromJson({
          ...postData,
          'username': postData['users']['username'],
          'display_name': postData['users']['display_name'],
          'avatar_url': postData['users']['avatar_url'],
          'is_liked_by_me': isLikedByMe,
        });
      }),
    );

    return posts;
  }

  @override
  Future<PostModel> createPost({
    required String userId,
    required String categoryId,
    required String title,
    required String content,
    List<String>? imageUrls,
    bool isNSFW = false,
    String? nsfwWarning,
  }) async {
    final postData = {
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'content': content,
      'image_urls': imageUrls ?? [],
      'is_nsfw': isNSFW,
      'nsfw_warning': nsfwWarning,
    };

    final response = await supabase
        .from('posts')
        .insert(postData)
        .select('''
          *,
          users!inner(username, display_name, avatar_url)
        ''')
        .single();

    return PostModel.fromJson({
      ...response,
      'username': response['users']['username'],
      'display_name': response['users']['display_name'],
      'avatar_url': response['users']['avatar_url'],
      'is_liked_by_me': false,
    });
  }

  @override
  Future<void> deletePost(String postId) async {
    await supabase.from('posts').delete().eq('id', postId);
  }

  @override
  Future<void> toggleLike(String userId, String postId) async {
    final existingLike = await supabase
        .from('likes')
        .select()
        .eq('user_id', userId)
        .eq('post_id', postId)
        .maybeSingle();

    if (existingLike != null) {
      // Unlike
      await supabase
          .from('likes')
          .delete()
          .eq('user_id', userId)
          .eq('post_id', postId);
    } else {
      // Like
      await supabase.from('likes').insert({
        'user_id': userId,
        'post_id': postId,
      });
    }
  }

  @override
  Future<List<CommentModel>> getComments(String postId) async {
    final currentUserId = supabase.auth.currentUser?.id;

    final response = await supabase
        .from('comments')
        .select('''
          *,
          users!inner(username, display_name, avatar_url)
        ''')
        .eq('post_id', postId)
        .eq('is_active', true)
        .order('created_at', ascending: true);

    final comments = await Future.wait(
      (response as List<dynamic>).map((commentData) async {
        bool isLikedByMe = false;
        if (currentUserId != null) {
          final likeCheck = await supabase
              .from('likes')
              .select()
              .eq('user_id', currentUserId)
              .eq('comment_id', commentData['id'])
              .maybeSingle();
          isLikedByMe = likeCheck != null;
        }

        return CommentModel.fromJson({
          ...commentData,
          'username': commentData['users']['username'],
          'display_name': commentData['users']['display_name'],
          'avatar_url': commentData['users']['avatar_url'],
          'is_liked_by_me': isLikedByMe,
        });
      }),
    );

    return comments;
  }

  @override
  Future<CommentModel> createComment({
    required String userId,
    required String postId,
    required String content,
  }) async {
    final response = await supabase
        .from('comments')
        .insert({
          'user_id': userId,
          'post_id': postId,
          'content': content,
        })
        .select('''
          *,
          users!inner(username, display_name, avatar_url)
        ''')
        .single();

    return CommentModel.fromJson({
      ...response,
      'username': response['users']['username'],
      'display_name': response['users']['display_name'],
      'avatar_url': response['users']['avatar_url'],
      'is_liked_by_me': false,
    });
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await supabase.from('comments').delete().eq('id', commentId);
  }

  @override
  Future<void> reportPost({
    required String reporterId,
    required String postId,
    required String reason,
    String? description,
  }) async {
    await supabase.from('reports').insert({
      'reporter_id': reporterId,
      'post_id': postId,
      'reason': reason,
      'description': description,
    });
  }
}
