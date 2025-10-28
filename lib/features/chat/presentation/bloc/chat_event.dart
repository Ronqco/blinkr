import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatLoadConversations extends ChatEvent {}

class ChatLoadMessages extends ChatEvent {
  final String conversationId;

  const ChatLoadMessages(this.conversationId);

  @override
  List<Object> get props => [conversationId];
}

class ChatSendMessage extends ChatEvent {
  final String conversationId;
  final String content;

  const ChatSendMessage({
    required this.conversationId,
    required this.content,
  });

  @override
  List<Object> get props => [conversationId, content];
}

class ChatMessageReceived extends ChatEvent {
  final String conversationId;

  const ChatMessageReceived(this.conversationId);

  @override
  List<Object> get props => [conversationId];
}

class ChatCheckMessageLimit extends ChatEvent {}

class ChatUnlockMessagesByAd extends ChatEvent {}
