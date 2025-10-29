import '../../domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.otherUserId,
    required super.otherUsername,
    required super.otherDisplayName,
    super.otherAvatarUrl,
    super.lastMessage,
    required super.lastMessageAt,
    super.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      otherUserId: json['other_user_id'] as String,
      otherUsername: json['other_username'] as String,
      otherDisplayName: json['other_display_name'] as String,
      otherAvatarUrl: json['other_avatar_url'] as String?,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: DateTime.parse(json['last_message_at'] as String),
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
}
