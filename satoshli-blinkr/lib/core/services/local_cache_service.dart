import 'package:hive_flutter/hive_flutter.dart';

class LocalCacheService {
  static final LocalCacheService _instance = LocalCacheService._internal();

  factory LocalCacheService() {
    return _instance;
  }

  LocalCacheService._internal();

  late Box<dynamic> _cacheBox;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();
    _cacheBox = await Hive.openBox('blinkr_cache');
    _initialized = true;
  }

  Future<void> saveData(String key, dynamic value) async {
    if (!_initialized) return;
    await _cacheBox.put(key, value);
  }

  dynamic getData(String key) {
    if (!_initialized) return null;
    return _cacheBox.get(key);
  }

  Future<void> deleteData(String key) async {
    if (!_initialized) return;
    await _cacheBox.delete(key);
  }

  Future<void> clearCache() async {
    if (!_initialized) return;
    await _cacheBox.clear();
  }

  int getCacheSize() {
    if (!_initialized) return 0;
    return _cacheBox.length;
  }

  bool hasKey(String key) {
    if (!_initialized) return false;
    return _cacheBox.containsKey(key);
  }
}
