// 📁 lib/features/chat/data/repositories/chat_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/encryption/encryption_service.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/message_limit_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final EncryptionService encryptionService;
  final SupabaseClient supabase;

  ChatRepositoryImpl(
    this.remoteDataSource,
    this.encryptionService,
    this.supabase,
  );

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      final conversations = await remoteDataSource.getConversations(userId);
      return Right(conversations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> getOrCreateConversation(
    String otherUserId,
  ) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      final conversation = await remoteDataSource.getOrCreateConversation(
        userId: userId,
        otherUserId: otherUserId,
      );
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId,
  ) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      final messages = await remoteDataSource.getMessages(conversationId);
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      final conversationData = await supabase
          .from('conversations')
          .select()
          .eq('id', conversationId)
          .single();
      
      final isUser1 = conversationData['user1_id'] == userId;
      final recipientId = isUser1 
          ? conversationData['user2_id'] 
          : conversationData['user1_id'];
      
      final recipientPublicKey = await _getRecipientPublicKey(recipientId);
      
      final aesKey = encryptionService.generateAESKey();
      
      final aesEncrypted = encryptionService.encryptWithAES(content, aesKey);
      
      final encryptedAESKey = encryptionService.encryptWithRSA(
        aesKey,
        recipientPublicKey,
      );

      final message = await remoteDataSource.sendMessage(
        userId: userId,
        conversationId: conversationId,
        encryptedContent: aesEncrypted['ciphertext']!,
        encryptionIv: aesEncrypted['iv']!,
        encryptedAESKey: encryptedAESKey,
      );

      return Right(message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<String> _getRecipientPublicKey(String recipientId) async {
    final response = await supabase
      .from('users')
      .select('public_key')
      .eq('id', recipientId)
      .single();
    
    return response['public_key'] as String;
  }

  @override
  Future<Either<Failure, void>> markAsRead(String conversationId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      await remoteDataSource.markAsRead(conversationId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageLimitEntity>> getMessageLimit() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      final result = await remoteDataSource.getMessageLimit(userId);

      return Right(MessageLimitEntity(
        messagesSent: 0,
        messagesUnlockedByAds: 0,
        messagesRemaining: result['messages_remaining'] as int,
        canSend: result['can_send'] as bool,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageLimitEntity>> unlockMessagesByAd() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      final unlockedCount = await remoteDataSource.unlockMessagesByAd(userId);

      return Right(MessageLimitEntity(
        messagesSent: 0,
        messagesUnlockedByAds: unlockedCount,
        messagesRemaining: unlockedCount,
        canSend: true,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<MessageEntity> subscribeToMessages(String conversationId) {
    return remoteDataSource.subscribeToMessages(conversationId);
  }
}
