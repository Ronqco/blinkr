import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Request location permission
  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Check if location permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  // Get current location (approximate for privacy)
  Future<Position?> getCurrentLocation() async {
    if (!await hasPermission()) {
      final granted = await requestPermission();
      if (!granted) return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // Low accuracy for privacy
      );
    } catch (e) {
      return null;
    }
  }

  // Calculate distance between two points in kilometers
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  // Add noise to location for privacy (±500m)
  Position addLocationNoise(Position position) {
    // Add random offset within ±500m
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    final latOffset = (random / 1000 - 0.5) * 0.009; // ~500m in degrees
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
