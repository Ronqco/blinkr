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
  Future<List<AchievementModel>> getUserAchievements(String userId, String categoryId) async {
    final response = await supabaseClient
        .from('achievements')
        .select('''
          *,
          user_achievements!left(unlocked_at)
        ''')
        .eq('category_id', categoryId);

    return (response as List).map((json) {
      final achievement = Map<String, dynamic>.from(json);
      final userAchievement = achievement['user_achievements'] as List?;
      
      return AchievementModel.fromJson({
        ...achievement,
        'is_unlocked': userAchievement != null && userAchievement.isNotEmpty,
        'unlocked_at': userAchievement != null && userAchievement.isNotEmpty
            ? userAchievement.first['unlocked_at']
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
