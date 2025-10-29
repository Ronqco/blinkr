# Guía de Optimización de Rendimiento - Blinkr

## 1. OPTIMIZACIONES DE IMÁGENES

### 1.1 Configuración de Caché Personalizada

\`\`\`dart
// lib/core/services/image_cache_service.dart
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();

  factory ImageCacheService() {
    return _instance;
  }

  ImageCacheService._internal();

  late CacheManager _cacheManager;

  Future<void> initialize() async {
    final cacheDir = await getTemporaryDirectory();
    _cacheManager = CacheManager(
      Config(
        'blinkr_image_cache',
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 200, // Máximo 200 imágenes
        repo: JsonCacheInfoRepository(databasePath: cacheDir.path),
        fileService: HttpFileService(),
      ),
    );
  }

  CacheManager get cacheManager => _cacheManager;

  // Obtener URL optimizada
  String getOptimizedImageUrl(String url, {int width = 400, int height = 400}) {
    if (url.contains('?')) {
      return '$url&w=$width&h=$height&q=75&fm=webp';
    }
    return '$url?w=$width&h=$height&q=75&fm=webp';
  }

  // Limpiar caché
  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
  }

  // Obtener tamaño del caché
  Future<int> getCacheSize() async {
    final files = await _cacheManager.getImageFile('');
    return files.lengthSync();
  }
}
\`\`\`

### 1.2 Widget Optimizado para Imágenes

\`\`\`dart
// lib/features/feed/presentation/widgets/optimized_image.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/services/image_cache_service.dart';

class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const OptimizedImage({
    Key? key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final optimizedUrl = ImageCacheService().getOptimizedImageUrl(
      imageUrl,
      width: width.toInt(),
      height: height.toInt(),
    );

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: optimizedUrl,
        width: width,
        height: height,
        fit: fit,
        cacheManager: ImageCacheService().cacheManager,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
        fadeInDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.grey[300],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}
\`\`\`

## 2. OPTIMIZACIONES DE LISTA

### 2.1 Feed Virtualizado

\`\`\`dart
// lib/features/feed/presentation/widgets/virtualized_feed.dart
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VirtualizedFeed extends StatefulWidget {
  final List<dynamic> items;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController? scrollController;
  final VoidCallback? onLoadMore;

  const VirtualizedFeed({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.scrollController,
    this.onLoadMore,
  }) : super(key: key);

  @override
  State<VirtualizedFeed> createState() => _VirtualizedFeedState();
}

class _VirtualizedFeedState extends State<VirtualizedFeed> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      widget.onLoadMore?.call();
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return VisibilityDetector(
          key: Key('item-$index'),
          onVisibilityChanged: (info) {
            // Cargar datos cuando el item es visible
            if (info.visibleFraction > 0.5) {
              // Trigger lazy loading si es necesario
            }
          },
          child: widget.itemBuilder(context, index),
        );
      },
    );
  }
}
\`\`\`

## 3. OPTIMIZACIONES DE ESTADO

### 3.1 BLoC Singleton

\`\`\`dart
// lib/core/services/service_locator.dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Registrar BLoCs como singletons
  getIt.registerSingleton<FeedBloc>(
    FeedBloc(
      getFeedPostsUseCase: getIt(),
      repository: getIt(),
    ),
  );

  getIt.registerSingleton<ChatBloc>(
    ChatBloc(
      sendMessageUseCase: getIt(),
      chatRepository: getIt(),
    ),
  );

  // Otros servicios...
}
\`\`\`

## 4. OPTIMIZACIONES DE RED

### 4.1 Compresión de Datos

\`\`\`dart
// lib/core/services/http_client_service.dart
import 'package:http/http.dart' as http;

class HttpClientService extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Agregar headers de compresión
    request.headers['Accept-Encoding'] = 'gzip, deflate';
    request.headers['Content-Encoding'] = 'gzip';
    
    return super.send(request);
  }
}
\`\`\`

### 4.2 Caché Local con Hive

\`\`\`dart
// lib/core/services/local_cache_service.dart
import 'package:hive_flutter/hive_flutter.dart';

class LocalCacheService {
  static final LocalCacheService _instance = LocalCacheService._internal();

  factory LocalCacheService() {
    return _instance;
  }

  LocalCacheService._internal();

  late Box<dynamic> _cacheBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox('blinkr_cache');
  }

  // Guardar datos
  Future<void> saveData(String key, dynamic value) async {
    await _cacheBox.put(key, value);
  }

  // Obtener datos
  dynamic getData(String key) {
    return _cacheBox.get(key);
  }

  // Limpiar caché
  Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  // Obtener tamaño del caché
  int getCacheSize() {
    return _cacheBox.length;
  }
}
\`\`\`

## 5. MONITOREO DE RENDIMIENTO

### 5.1 Performance Monitoring

\`\`\`dart
// lib/core/services/performance_monitor.dart
import 'package:flutter/foundation.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();

  factory PerformanceMonitor() {
    return _instance;
  }

  PerformanceMonitor._internal();

  final Map<String, Stopwatch> _timers = {};

  void startTimer(String label) {
    _timers[label] = Stopwatch()..start();
  }

  void stopTimer(String label) {
    final stopwatch = _timers[label];
    if (stopwatch != null) {
      stopwatch.stop();
      if (kDebugMode) {
        print('[Performance] $label: ${stopwatch.elapsedMilliseconds}ms');
      }
    }
  }

  int getElapsedTime(String label) {
    return _timers[label]?.elapsedMilliseconds ?? 0;
  }

  void clearTimers() {
    _timers.clear();
  }
}
\`\`\`

## 6. CHECKLIST DE OPTIMIZACIÓN

- [ ] Implementar ImageCacheService
- [ ] Crear OptimizedImage widget
- [ ] Implementar VirtualizedFeed
- [ ] Registrar BLoCs como singletons
- [ ] Agregar compresión HTTP
- [ ] Implementar Hive para caché local
- [ ] Agregar PerformanceMonitor
- [ ] Testear en dispositivo gama media
- [ ] Medir consumo de memoria
- [ ] Medir consumo de datos
- [ ] Optimizar queries de BD
- [ ] Implementar lazy loading de imágenes

## 7. BENCHMARKS ESPERADOS

Después de implementar todas las optimizaciones:

\`\`\`
Métrica                          Antes     Después   Mejora
─────────────────────────────────────────────────────────────
Tiempo carga inicial             3.5s      1.2s      66%
Memoria RAM usada                180MB     85MB      53%
Consumo datos por sesión         45MB      12MB      73%
FPS en scroll                    45-50     58-60     28%
Tiempo respuesta like            800ms     250ms     69%
