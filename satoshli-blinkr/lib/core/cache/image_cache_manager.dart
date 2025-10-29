import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class BlinkrCacheManager extends CacheManager {
  static const key = 'blinkrCache';
  static BlinkrCacheManager? _instance;

  factory BlinkrCacheManager() =>
      _instance ??= BlinkrCacheManager._();

  BlinkrCacheManager._()
      : super(Config(key, stalePeriod: Duration(days: 7), maxNrOfCacheObjects: 200));
}
