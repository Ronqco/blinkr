import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';
import '../entities/message_limit_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ConversationEntity>>> getConversations();

  Future<Either<Failure, ConversationEntity>> getOrCreateConversation(
    String otherUserId,
  );

  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId,
  );

  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String content,
  });

  Future<Either<Failure, void>> markAsRead(String conversationId);

  Future<Either<Failure, MessageLimitEntity>> getMessageLimit();

  Future<Either<Failure, MessageLimitEntity>> unlockMessagesByAd();

  Stream<MessageEntity> subscribeToMessages(String conversationId);
}
