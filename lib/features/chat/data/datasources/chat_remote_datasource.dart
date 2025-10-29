// 📁 lib/features/chat/data/datasources/chat_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/encryption/encryption_service.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ConversationModel>> getConversations(String userId);
  
  Future<ConversationModel> getOrCreateConversation({
    required String userId,
    required String otherUserId,
  });
  
  Future<List<MessageModel>> getMessages(String conversationId);
  
  Future<MessageModel> sendMessage({
    required String userId,
    required String conversationId,
    required String encryptedContent,
    required String encryptionIv,
    required String encryptedAESKey,
  });
  
  Future<void> markAsRead(String conversationId, String userId);
  
  Future<Map<String, dynamic>> getMessageLimit(String userId);
  
  Future<void> incrementMessageCount(String userId);
  
  Future<int> unlockMessagesByAd(String userId);
  
  Stream<MessageModel> subscribeToMessages(String conversationId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient supabase;
  final EncryptionService encryptionService;

  ChatRemoteDataSourceImpl(this.supabase, this.encryptionService);

  @override
  Future<List<ConversationModel>> getConversations(String userId) async {
    final response = await supabase
        .from('conversations')
        .select('''
          *,
          user1:users!conversations_user1_id_fkey(id, username, display_name, avatar_url),
          user2:users!conversations_user2_id_fkey(id, username, display_name, avatar_url)
        ''')
        .or('user1_id.eq.$userId,user2_id.eq.$userId')
        .order('last_message_at', ascending: false);

    final conversations = (response as List<dynamic>).map((conv) {
      final isUser1 = conv['user1_id'] == userId;
      final otherUser = isUser1 ? conv['user2'] : conv['user1'];

      return ConversationModel.fromJson({
        'id': conv['id'],
        'other_user_id': otherUser['id'],
        'other_username': otherUser['username'],
        'other_display_name': otherUser['display_name'],
        'other_avatar_url': otherUser['avatar_url'],
        'last_message_at': conv['last_message_at'],
        'unread_count': 0,
      });
    }).toList();

    return conversations;
  }

  @override
  Future<ConversationModel> getOrCreateConversation({
    required String userId,
    required String otherUserId,
  }) async {
    final existing = await supabase
        .from('conversations')
        .select('''
          *,
          user1:users!conversations_user1_id_fkey(id, username, display_name, avatar_url),
          user2:users!conversations_user2_id_fkey(id, username, display_name, avatar_url)
        ''')
        .or('and(user1_id.eq.$userId,user2_id.eq.$otherUserId),and(user1_id.eq.$otherUserId,user2_id.eq.$userId)')
        .maybeSingle();

    if (existing != null) {
      final isUser1 = existing['user1_id'] == userId;
      final otherUser = isUser1 ? existing['user2'] : existing['user1'];

      return ConversationModel.fromJson({
        'id': existing['id'],
        'other_user_id': otherUser['id'],
        'other_username': otherUser['username'],
        'other_display_name': otherUser['display_name'],
        'other_avatar_url': otherUser['avatar_url'],
        'last_message_at': existing['last_message_at'],
        'unread_count': 0,
      });
    }

    final newConv = await supabase
        .from('conversations')
        .insert({
          'user1_id': userId,
          'user2_id': otherUserId,
        })
        .select('''
          *,
          user1:users!conversations_user1_id_fkey(id, username, display_name, avatar_url),
          user2:users!conversations_user2_id_fkey(id, username, display_name, avatar_url)
        ''')
        .single();

    final otherUser = newConv['user2'];

    return ConversationModel.fromJson({
      'id': newConv['id'],
      'other_user_id': otherUser['id'],
      'other_username': otherUser['username'],
      'other_display_name': otherUser['display_name'],
      'other_avatar_url': otherUser['avatar_url'],
      'last_message_at': newConv['last_message_at'],
      'unread_count': 0,
    });
  }

  @override
  Future<MessageModel> sendMessage({
    required String userId,
    required String conversationId,
    required String encryptedContent,
    required String encryptionIv,
    required String encryptedAESKey,
  }) async {
    final response = await supabase
        .from('messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': userId,
          'encrypted_content': encryptedContent,
          'encryption_iv': encryptionIv,
          'encrypted_aes_key': encryptedAESKey,
        })
        .select()
        .single();

    await incrementMessageCount(userId);

    final decryptedContent = await encryptionService.decryptMessage(
      response['encrypted_aes_key'],
    );

    return MessageModel.fromJson({
      ...response,
      'content': decryptedContent,
    });
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    final response = await supabase
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    final messages = await Future.wait(
      (response as List<dynamic>).map((msg) async {
        try {
          final decryptedContent = await encryptionService.decryptMessage(
            msg['encrypted_aes_key'],
          );

          return MessageModel.fromJson({
            ...msg,
            'content': decryptedContent,
          });
        } catch (e) {
          return MessageModel.fromJson({
            ...msg,
            'content': '[Mensaje encriptado - no se pudo desencriptar]',
          });
        }
      }),
    );

    return messages;
  }

  @override
  Future<void> markAsRead(String conversationId, String userId) async {
    await supabase
        .from('messages')
        .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
        .eq('conversation_id', conversationId)
        .neq('sender_id', userId)
        .eq('is_read', false);
  }

  @override
  Future<Map<String, dynamic>> getMessageLimit(String userId) async {
    final result = await supabase.rpc('check_message_limit', params: {
      'p_user_id': userId,
      'p_is_premium': false,
    });

    return {
      'can_send': result[0]['can_send'] as bool,
      'messages_remaining': result[0]['messages_remaining'] as int,
    };
  }

  @override
  Future<void> incrementMessageCount(String userId) async {
    await supabase.rpc('increment_message_count', params: {
      'p_user_id': userId,
    });
  }

  @override
  Future<int> unlockMessagesByAd(String userId) async {
    final result = await supabase.rpc('unlock_messages_by_ad', params: {
      'p_user_id': userId,
      'p_messages_to_unlock': 10,
    });

    return result as int;
  }

  @override
  Stream<MessageModel> subscribeToMessages(String conversationId) {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .asyncMap((messages) async {
          if (messages.isEmpty) return null;
          
          final msg = messages.last;
          final decryptedContent = await encryptionService.decryptMessage(
            msg['encrypted_content'],
          );

          return MessageModel.fromJson({
            ...msg,
            'content': decryptedContent,
          });
        })
        .where((msg) => msg != null)
        .cast<MessageModel>();
  }
}