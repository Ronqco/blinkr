import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // App Configuration
  static const String appName = 'Blinkr';
  static const String appVersion = '2.0.0';
  
  // Geolocation Configuration
  static const double proximityRadiusKm = 50.0; // 50km default radius
  static const double locationAccuracyMeters = 500.0; // ±500m privacy
  
  // Chat Configuration
  static const int freeMessagesPerDay = 50;
  static const int messageLengthLimit = 1000;
  
  // Premium Configuration
  static const double premiumPriceUSD = 2.99;
  static const String premiumProductId = 'blinkr_premium_monthly';
  
  // Ad Configuration
  static const int messagesUnlockedPerAd = 10;
  static const String adUnitIdAndroid = 'ca-app-pub-xxxxx/xxxxx';
  static const String adUnitIdIOS = 'ca-app-pub-xxxxx/xxxxx';
  
  // Content Moderation
  static const bool allowNSFWContent = true;
  static const bool requireNSFWOptIn = true;
  
  // Gamification
  static const int xpPerPost = 10;
  static const int xpPerComment = 5;
  static const int xpPerLike = 1;
  static const int xpPerMatch = 20;
  
  // Feed Configuration
  static const int postsPerPage = 20;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB

  /// Valida variables críticas
  static void validateConfig() {
    if (supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL is missing in .env file');
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY is missing in .env file');
    }
  }
}
