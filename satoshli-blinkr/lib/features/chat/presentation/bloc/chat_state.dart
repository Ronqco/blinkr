import 'package:equatable/equatable.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/message_limit_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatConversationsLoaded extends ChatState {
  final List<ConversationEntity> conversations;

  const ChatConversationsLoaded(this.conversations);

  @override
  List<Object> get props => [conversations];
}

class ChatMessagesLoaded extends ChatState {
  final List<MessageEntity> messages;
  final MessageLimitEntity? messageLimit;

  const ChatMessagesLoaded({
    required this.messages,
    this.messageLimit,
  });

  @override
  List<Object?> get props => [messages, messageLimit];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}

class ChatMessageLimitReached extends ChatState {
  final MessageLimitEntity limit;

  const ChatMessageLimitReached(this.limit);

  @override
  List<Object> get props => [limit];
}
