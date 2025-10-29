import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<bool> hasPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  Future<Position?> getCurrentLocation() async {
    if (!await hasPermission()) {
      final granted = await requestPermission();
      if (!granted) return null;
    }

    try {
      // ✅ Usar LocationSettings en lugar de desiredAccuracy
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          distanceFilter: 100,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  Position addLocationNoise(Position position) {
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    final latOffset = (random / 1000 - 0.5) * 0.009;
    final lonOffset = (random / 1000 - 0.5) * 0.009;

    return Position(
      latitude: position.latitude + latOffset,
      longitude: position.longitude + lonOffset,
      timestamp: position.timestamp,
      accuracy: position.accuracy,
      altitude: position.altitude,
      heading: position.heading,
      speed: position.speed,
      speedAccuracy: position.speedAccuracy,
      altitudeAccuracy: position.altitudeAccuracy,
      headingAccuracy: position.headingAccuracy,
    );
  }
}
