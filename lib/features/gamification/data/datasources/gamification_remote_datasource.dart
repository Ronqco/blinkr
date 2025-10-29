import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_xp_model.dart';
import '../models/achievement_model.dart';

abstract class GamificationRemoteDataSource {
  Future<List<UserXpModel>> getUserXp(String userId);
  Future<UserXpModel> getCategoryXp(String userId, String categoryId);
  Future<void> addXp(String userId, String categoryId, int xp);
  Future<List<AchievementModel>> getUserAchievements(String userId, String categoryId);
  Future<List<UserXpModel>> getLeaderboard(String categoryId, {int limit = 50});
}

class GamificationRemoteDataSourceImpl implements GamificationRemoteDataSource {
  final SupabaseClient supabaseClient;

  GamificationRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<UserXpModel>> getUserXp(String userId) async {
    final response = await supabaseClient
        .from('user_xp')
        .select()
        .eq('user_id', userId)
        .order('xp', ascending: false);

    return (response as List).map((json) => UserXpModel.fromJson(json)).toList();
  }

  @override
  Future<UserXpModel> getCategoryXp(String userId, String categoryId) async {
    final response = await supabaseClient
        .from('user_xp')
        .select()
        .eq('user_id', userId)
        .eq('category_id', categoryId)
        .single();

    return UserXpModel.fromJson(response);
  }

  @override
  Future<void> addXp(String userId, String categoryId, int xp) async {
    await supabaseClient.rpc('add_user_xp', params: {
      'p_user_id': userId,
      'p_category_id': categoryId,
      'p_xp_amount': xp,
    });
  }

  @override
  Future<List<AchievementModel>> getUserAchievements(
  String userId, 
  String categoryId
) async {
  // ✅ Query corregida
  final response = await supabaseClient
      .from('achievements')
      .select('''
        id,
        name,
        description,
        icon_url,
        category_id,
        required_xp,
        user_achievements!left(unlocked_at)
      ''')
      .eq('category_id', categoryId);

  return (response as List).map((json) {
    final userAchievements = json['user_achievements'] as List?;
    final isUnlocked = userAchievements != null && 
                       userAchievements.isNotEmpty &&
                       userAchievements.any((ua) => ua['user_id'] == userId);
    
    return AchievementModel.fromJson({
      'id': json['id'],
      'category_id': json['category_id'],
      'name': json['name'],
      'description': json['description'],
      'icon_url': json['icon_url'],
      'required_xp': json['required_xp'],
      'is_unlocked': isUnlocked,
      'unlocked_at': isUnlocked && userAchievements.isNotEmpty
          ? userAchievements.first['unlocked_at']
          : null,
    });
  }).toList();
}

  @override
  Future<List<UserXpModel>> getLeaderboard(String categoryId, {int limit = 50}) async {
    final response = await supabaseClient
        .from('user_xp')
        .select()
        .eq('category_id', categoryId)
        .order('xp', ascending: false)
        .limit(limit);

    return (response as List).map((json) => UserXpModel.fromJson(json)).toList();
  }
}
