import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, MessageEntity>> call({
    required String conversationId,
    required String content,
  }) async {
    return await repository.sendMessage(
      conversationId: conversationId,
      content: content,
    );
  }
}
