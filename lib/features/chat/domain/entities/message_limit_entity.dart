import 'package:equatable/equatable.dart';

class MessageLimitEntity extends Equatable {
  final int messagesSent;
  final int messagesUnlockedByAds;
  final int messagesRemaining;
  final bool canSend;

  const MessageLimitEntity({
    required this.messagesSent,
    required this.messagesUnlockedByAds,
    required this.messagesRemaining,
    required this.canSend,
  });

  int get totalAllowed => 50 + messagesUnlockedByAds;

  @override
  List<Object> get props => [
        messagesSent,
        messagesUnlockedByAds,
        messagesRemaining,
        canSend,
      ];
}
