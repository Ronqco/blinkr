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
      // Obtener intereses del usuario actual
      final currentUserInterestsResponse = await supabase
          .from('user_interests')
          .select('category_id')
          .eq('user_id', currentUserId);

      final myInterests = (currentUserInterestsResponse as List<dynamic>)
          .map((e) => e['category_id'] as String)
          .toSet();

      // Llamar a la función Postgres get_nearby_users()
      final response = await supabase.rpc(
        'get_nearby_users',
        params: {
          'user_location': 'SRID=4326;POINT($longitude $latitude)',
          'radius_km': radiusKm,
          'limit_count': 50,
        },
      );

      if (response == null || response is! List) {
        throw Exception('Invalid response from get_nearby_users');
      }

      // Procesar los usuarios obtenidos
      final users = response.map((userData) async {
        final userId = userData['id'] as String?;

        if (userId == null) return null;

        // Obtener intereses de cada usuario cercano
        final interestsResponse = await supabase
            .from('user_interests')
            .select('category_id')
            .eq('user_id', userId);

        final userInterests = (interestsResponse as List<dynamic>)
            .map((e) => e['category_id'] as String)
            .toList();

        // Calcular intereses en común
        final commonInterests =
            userInterests.where((i) => myInterests.contains(i)).toList();

        // Calcular edad
        final dateOfBirthStr = userData['date_of_birth'];
        int age = 0;
        if (dateOfBirthStr != null) {
          final dateOfBirth = DateTime.tryParse(dateOfBirthStr);
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
          ...userData,
          'age': age,
          'interests': userInterests,
          'common_interests': commonInterests,
        });
      }).toList();

      // Esperar a que se resuelvan todas las llamadas
      final resolvedUsers = (await Future.wait(users)).whereType<NearbyUserModel>().toList();

      // Filtro opcional por intereses
      List<NearbyUserModel> filteredUsers = resolvedUsers;
      if (filterByInterests != null && filterByInterests.isNotEmpty) {
        filteredUsers = resolvedUsers
            .where((user) => user.interests
                .any((interest) => filterByInterests.contains(interest)))
            .toList();
      }

      // Ordenar por número de intereses en común (descendente)
      filteredUsers.sort((a, b) =>
          b.commonInterests.length.compareTo(a.commonInterests.length));

      return filteredUsers;
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
