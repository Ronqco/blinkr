import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final String id;
  final String otherUserId;
  final String otherUsername;
  final String otherDisplayName;
  final String? otherAvatarUrl;
  final String? lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  const ConversationEntity({
    required this.id,
    required this.otherUserId,
    required this.otherUsername,
    required this.otherDisplayName,
    this.otherAvatarUrl,
    this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        otherUserId,
        otherUsername,
        otherDisplayName,
        otherAvatarUrl,
        lastMessage,
        lastMessageAt,
        unreadCount,
      ];
}
