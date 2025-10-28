import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // ✅ AÑADIR
import '../../../../core/encryption/encryption_service.dart'; // ✅ AÑADIR
import '../../../../core/storage/secure_storage_service.dart'; // ✅ AÑADIR
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String username,
    required String displayName,
    required DateTime dateOfBirth,
    String? gender,
  });
  Future<void> signOut();
  Future<UserModel> getCurrentUser();
  Future<UserModel> updateProfile(Map<String, dynamic> updates);
  Future<void> updateInterests(String userId, List<String> interests);
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl(this.supabase);

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Sign in failed');
    }

    return await _getUserProfile(response.user!.id);
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String username,
    required String displayName,
    required DateTime dateOfBirth,
    String? gender,
  }) async {
    final existingUser = await supabase
        .from('users')
        .select()
        .eq('username', username)
        .maybeSingle();

    if (existingUser != null) {
      throw Exception('Username already taken');
    }

    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Sign up failed');
    }

    // ✅ Generar claves de encriptación
    final secureStorage = SecureStorageService(const FlutterSecureStorage());
    final encryptionService = EncryptionService(secureStorage);
    final keyPair = await encryptionService.generateKeyPair();

    final userProfile = {
      'id': response.user!.id,
      'email': email,
      'username': username,
      'display_name': displayName,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'public_key': keyPair['publicKey'],
    };

    await supabase.from('users').insert(userProfile);

    return await _getUserProfile(response.user!.id);
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    return await _getUserProfile(user.id);
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> updates) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('No user logged in');
    }

    await supabase.from('users').update(updates).eq('id', userId);

    return await _getUserProfile(userId);
  }

  @override
  Future<void> updateInterests(String userId, List<String> interests) async {
    await supabase.from('user_interests').delete().eq('user_id', userId);

    if (interests.isNotEmpty) {
      final interestRecords = interests
          .map((categoryId) => {
                'user_id': userId,
                'category_id': categoryId,
              })
          .toList();

      await supabase.from('user_interests').insert(interestRecords);
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return supabase.auth.onAuthStateChange.asyncMap((event) async {
      if (event.session?.user != null) {
        return await _getUserProfile(event.session!.user.id);
      }
      return null;
    });
  }

  Future<UserModel> _getUserProfile(String userId) async {
    final response = await supabase
        .from('users')
        .select('*, user_interests(category_id)')
        .eq('id', userId)
        .single();

    final interests = (response['user_interests'] as List<dynamic>?)
            ?.map((e) => e['category_id'] as String)
            .toList() ??
        [];

    final userData = Map<String, dynamic>.from(response);
    userData['interests'] = interests;
    userData.remove('user_interests');

    return UserModel.fromJson(userData);
  }
}