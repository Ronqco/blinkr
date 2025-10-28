import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/nearby_user_model.dart';

abstract class DiscoveryRemoteDataSource {
  Future<List<NearbyUserModel>> getNearbyUsers({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
    List<String>? filterByInterests,
  });

  Future<void> updateLocation({
    required String userId,
    required double latitude,
    required double longitude,
  });
}

class DiscoveryRemoteDataSourceImpl implements DiscoveryRemoteDataSource {
  final SupabaseClient supabase;

  DiscoveryRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<NearbyUserModel>> getNearbyUsers({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
    List<String>? filterByInterests,
  }) async {
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Get current user's interests for common interests calculation
    final currentUserInterests = await supabase
        .from('user_interests')
        .select('category_id')
        .eq('user_id', currentUserId);

    final myInterests = (currentUserInterests as List<dynamic>)
        .map((e) => e['category_id'] as String)
        .toSet();

    // Call the PostgreSQL function to get nearby users
    final response = await supabase.rpc(
      'get_nearby_users',
      params: {
        'user_location': 'POINT($longitude $latitude)',
        'radius_km': radiusKm,
        'limit_count': 50,
      },
    );

    final users = (response as List<dynamic>).map((userData) {
      // Get user interests
      return supabase
          .from('user_interests')
          .select('category_id')
          .eq('user_id', userData['id'])
          .then((interests) {
        final userInterests = (interests as List<dynamic>)
            .map((e) => e['category_id'] as String)
            .toList();

        // Calculate common interests
        final commonInterests =
            userInterests.where((i) => myInterests.contains(i)).toList();

        // Calculate age
        final dateOfBirth = DateTime.parse(userData['date_of_birth']);
        final age = DateTime.now().year - dateOfBirth.year;

        return NearbyUserModel.fromJson({
          ...userData,
          'age': age,
          'interests': userInterests,
          'common_interests': commonInterests,
        });
      });
    }).toList();

    final resolvedUsers = await Future.wait(users);

    // Filter by interests if specified
    if (filterByInterests != null && filterByInterests.isNotEmpty) {
      return resolvedUsers
          .where((user) => user.interests
              .any((interest) => filterByInterests.contains(interest)))
          .toList();
    }

    // Sort by common interests count (descending)
    resolvedUsers.sort((a, b) =>
        b.commonInterests.length.compareTo(a.commonInterests.length));

    return resolvedUsers;
  }

  @override
  Future<void> updateLocation({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    await supabase.from('users').update({
      'location': 'POINT($longitude $latitude)',
      'location_updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }
}
