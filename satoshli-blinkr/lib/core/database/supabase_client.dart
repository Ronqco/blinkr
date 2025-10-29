import 'dart:typed_data';  // ← AGREGADO
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  static SupabaseClient get client => Supabase.instance.client;
  
  // Auth
  static User? get currentUser => client.auth.currentUser;
  static String? get currentUserId => currentUser?.id;
  
  // Realtime subscriptions
  static RealtimeChannel subscribeToMessages(
    String conversationId,
    void Function(Map<String, dynamic>) onMessage,
  ) {
    return client
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) => onMessage(payload.newRecord),
        )
        .subscribe();
  }
  
  static RealtimeChannel subscribeToUserStatus(
    String userId,
    void Function(Map<String, dynamic>) onStatusChange,
  ) {
    return client
        .channel('user_status:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'users',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: userId,
          ),
          callback: (payload) => onStatusChange(payload.newRecord),
        )
        .subscribe();
  }
  
  // Storage - CORREGIDO
  static Future<String> uploadImage(String bucket, String path, List<int> bytes) async {
    await client.storage.from(bucket).uploadBinary(path, Uint8List.fromList(bytes));  // ← CORREGIDO
    return client.storage.from(bucket).getPublicUrl(path);
  }
  
  static Future<void> deleteImage(String bucket, String path) async {
    await client.storage.from(bucket).remove([path]);
  }
}
