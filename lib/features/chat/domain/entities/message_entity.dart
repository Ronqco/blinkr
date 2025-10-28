import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.isRead = false,
    required this.createdAt,
  });

  bool isMine(String currentUserId) => senderId == currentUserId;

  @override
  List<Object> get props => [
        id,
        conversationId,
        senderId,
        content,
        isRead,
        createdAt,
      ];
}
