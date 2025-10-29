import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();

  factory ImageCacheService() {
    return _instance;
  }

  ImageCacheService._internal();

  late CacheManager _cacheManager;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    final cacheDir = await getTemporaryDirectory();
    _cacheManager = CacheManager(
      Config(
        'blinkr_image_cache',
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 200,
        repo: JsonCacheInfoRepository(cacheDir.path),
        fileService: HttpFileService(),
      ),
    );
    _initialized = true;
  }

  CacheManager get cacheManager {
    if (!_initialized) {
      throw Exception('ImageCacheService not initialized. Call initialize() first.');
    }
    return _cacheManager;
  }

  String getOptimizedImageUrl(
    String url, {
    int width = 400,
    int height = 400,
    int quality = 75,
  }) {
    if (url.isEmpty) return url;

    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}w=$width&h=$height&q=$quality&fm=webp';
  }

  String getThumbnailUrl(String url) {
    return getOptimizedImageUrl(url, width: 64, height: 64, quality: 60);
  }

  String getPreviewUrl(String url) {
    return getOptimizedImageUrl(url, width: 200, height: 200, quality: 70);
  }

  Future<void> clearCache() async {
    if (!_initialized) return;
    await _cacheManager.emptyCache();
  }

  Future<void> clearOldCache() async {
    if (!_initialized) return;
    await _cacheManager.emptyCache();
  }
}
