class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ppbjuicqobgzvadfxuap.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBwYmp1aWNxb2JnenZhZGZ4dWFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE2MjIyODksImV4cCI6MjA3NzE5ODI4OX0.dng6b8H8wEnfUDGpeVlzccDAmkW3OulK_KgFthUvDuQ',
  );
  
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
}
