// 🔧 CAMBIOS:
// - Líneas 40-120: ELIMINADO loop con N queries
// - Líneas 40-80: NUEVO llamado a función SQL optimizada

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

    try {
      // ✅ CORREGIDO: Una sola llamada SQL optimizada
      final response = await supabase.rpc(
        'get_nearby_users_optimized',
        params: {
          'p_user_id': currentUserId,
          'p_user_lat': latitude,
          'p_user_lon': longitude,
          'p_radius_km': radiusKm,
          'p_limit': 50,
        },
      );

      if (response == null || response is! List) {
        throw Exception('Invalid response from get_nearby_users_optimized');
      }

      // ✅ NUEVO: Mapeo directo sin queries adicionales
      final users = (response).map((userData) {
        // Calcular edad desde date_of_birth
        int age = 0;
        if (userData['date_of_birth'] != null) {
          final dateOfBirth = DateTime.tryParse(userData['date_of_birth']);
          if (dateOfBirth != null) {
            final now = DateTime.now();
            age = now.year - dateOfBirth.year;
            if (now.month < dateOfBirth.month ||
                (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
              age--;
            }
          }
        }

        return NearbyUserModel.fromJson({
          'id': userData['id'],
          'username': userData['username'],
          'display_name': userData['display_name'],
          'avatar_url': userData['avatar_url'],
          'bio': userData['bio'],
          'age': age,
          'distance_km': userData['distance_km'],
          'is_premium': userData['is_premium'] ?? false,
          'last_seen_at': userData['last_seen_at'],
          'interests': List<String>.from(userData['interests'] ?? []),
          'common_interests': List<String>.from(userData['common_interests'] ?? []),
        });
      }).toList();

      // ✅ NUEVO: Filtro opcional por intereses (ya pre-calculados)
      if (filterByInterests != null && filterByInterests.isNotEmpty) {
        return users.where((user) => 
          user.interests.any((interest) => filterByInterests.contains(interest))
        ).toList();
      }

      return users;
    } catch (e) {
      throw Exception('Error fetching nearby users: $e');
    }
  }

  @override
  Future<void> updateLocation({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await supabase.from('users').update({
        'location': 'SRID=4326;POINT($longitude $latitude)',
        'location_updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Error updating user location: $e');
    }
  }
}
