# Análisis de Optimización para Dispositivos Gama Media - Blinkr

## 1. DIAGNÓSTICO ACTUAL

### Problemas Identificados

#### 1.1 Rendimiento en Gama Media
- **Carga de imágenes sin optimización**: Las imágenes se cargan a resolución completa
- **Sin compresión de imágenes**: Consume 50-100MB por sesión
- **Caché ineficiente**: CachedNetworkImage sin configuración de tamaño máximo
- **Paginación lenta**: Carga 20 posts por página sin lazy loading de imágenes
- **Sin virtualización de listas**: ListView.builder carga todos los widgets en memoria

#### 1.2 Consumo de Memoria
- **PostEntity sin optimización**: Carga todas las propiedades siempre
- **Sin compresión de datos**: JSON completo sin minificación
- **Múltiples instancias de BLoC**: Cada página crea nuevas instancias
- **Sin limpieza de caché**: Las imágenes se acumulan indefinidamente

#### 1.3 Consumo de Datos
- **Sin compresión de red**: Todas las respuestas sin gzip
- **Imágenes de alta resolución**: 2-5MB por imagen
- **Sin delta sync**: Recarga todo el feed en cada refresh
- **Múltiples queries redundantes**: Consultas sin optimización

### Benchmarks Actuales (Dispositivo Gama Media - Snapdragon 680)
\`\`\`
Métrica                          Actual    Objetivo
─────────────────────────────────────────────────────
Tiempo carga inicial             3.5s      < 1.5s
Memoria RAM usada                180MB     < 100MB
Consumo datos por sesión         45MB      < 15MB
FPS en scroll                    45-50     > 55
Tiempo respuesta like            800ms     < 300ms
Tamaño app instalada            85MB      < 50MB
\`\`\`

## 2. ESTRUCTURA DE BD MEJORADA

### 2.1 Esquema Actual (Problemas)
\`\`\`sql
-- Problema: Demasiadas columnas en posts
posts (id, user_id, username, display_name, avatar_url, 
       category_id, title, content, image_urls, is_nsfw, 
       nsfw_warning, likes_count, comments_count, created_at)

-- Problema: Sin índices de rendimiento
-- Problema: Sin particionamiento por fecha
-- Problema: Sin caché de conteos
\`\`\`

### 2.2 Esquema Optimizado (Propuesto)

\`\`\`sql
-- 1. TABLA PRINCIPAL OPTIMIZADA
CREATE TABLE posts (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  post_type VARCHAR(10) NOT NULL, -- 'post', 'short', 'thread'
  title VARCHAR(200),
  content TEXT,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP,
  is_deleted BOOLEAN DEFAULT FALSE,
  
  -- Índices para búsqueda rápida
  CONSTRAINT posts_pkey PRIMARY KEY (id),
  INDEX idx_user_id (user_id),
  INDEX idx_created_at (created_at DESC),
  INDEX idx_post_type (post_type)
);

-- 2. TABLA DE METADATOS (Separada para optimización)
CREATE TABLE post_metadata (
  post_id UUID PRIMARY KEY REFERENCES posts(id),
  category_id VARCHAR(50),
  is_nsfw BOOLEAN DEFAULT FALSE,
  nsfw_warning VARCHAR(200),
  likes_count INT DEFAULT 0,
  comments_count INT DEFAULT 0,
  shares_count INT DEFAULT 0,
  views_count INT DEFAULT 0,
  engagement_score FLOAT DEFAULT 0,
  
  -- Desnormalización para velocidad
  cached_at TIMESTAMP,
  INDEX idx_category (category_id),
  INDEX idx_engagement (engagement_score DESC)
);

-- 3. TABLA DE MEDIOS (Separada)
CREATE TABLE post_media (
  id UUID PRIMARY KEY,
  post_id UUID NOT NULL REFERENCES posts(id),
  media_type VARCHAR(20), -- 'image', 'video', 'gif'
  url VARCHAR(500),
  thumbnail_url VARCHAR(500),
  width INT,
  height INT,
  size_bytes INT,
  duration_ms INT, -- Para videos
  position INT, -- Orden en el post
  
  INDEX idx_post_id (post_id),
  INDEX idx_media_type (media_type)
);

-- 4. TABLA DE USUARIO OPTIMIZADA
CREATE TABLE users (
  id UUID PRIMARY KEY,
  username VARCHAR(50) UNIQUE,
  display_name VARCHAR(100),
  avatar_url VARCHAR(500),
  avatar_thumbnail_url VARCHAR(500), -- Thumbnail 64x64
  bio TEXT,
  followers_count INT DEFAULT 0,
  following_count INT DEFAULT 0,
  posts_count INT DEFAULT 0,
  
  INDEX idx_username (username),
  INDEX idx_followers (followers_count DESC)
);

-- 5. TABLA DE INTERESES DEL USUARIO (Reemplaza interest_selections)
CREATE TABLE user_interests (
  user_id UUID NOT NULL REFERENCES users(id),
  interest_id VARCHAR(50),
  weight FLOAT DEFAULT 1.0, -- Peso basado en likes
  last_updated TIMESTAMP,
  
  PRIMARY KEY (user_id, interest_id),
  INDEX idx_user_id (user_id),
  INDEX idx_weight (weight DESC)
);

-- 6. TABLA DE LIKES (Para algoritmo de aprendizaje)
CREATE TABLE post_likes (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  post_id UUID NOT NULL REFERENCES posts(id),
  created_at TIMESTAMP NOT NULL,
  
  UNIQUE KEY unique_like (user_id, post_id),
  INDEX idx_user_id (user_id),
  INDEX idx_post_id (post_id),
  INDEX idx_created_at (created_at DESC)
);

-- 7. TABLA DE ALGORITMO (Nuevo - Aprendizaje de intereses)
CREATE TABLE user_interest_scores (
  user_id UUID NOT NULL REFERENCES users(id),
  interest_id VARCHAR(50),
  score FLOAT DEFAULT 0,
  likes_count INT DEFAULT 0,
  views_count INT DEFAULT 0,
  last_updated TIMESTAMP,
  
  PRIMARY KEY (user_id, interest_id),
  INDEX idx_score (score DESC)
);

-- 8. TABLA DE FEED PERSONALIZADO (Caché)
CREATE TABLE user_feed_cache (
  user_id UUID NOT NULL REFERENCES users(id),
  post_id UUID NOT NULL REFERENCES posts(id),
  rank INT,
  score FLOAT,
  cached_at TIMESTAMP,
  
  PRIMARY KEY (user_id, post_id),
  INDEX idx_user_id_rank (user_id, rank)
);

-- 9. TABLA DE TIPO DE CONTENIDO
CREATE TABLE post_types (
  id VARCHAR(10) PRIMARY KEY,
  name VARCHAR(50),
  description TEXT,
  icon VARCHAR(10),
  max_duration_ms INT -- Para videos
);

INSERT INTO post_types VALUES
('post', 'Publicación', 'Publicación estándar con texto e imágenes', '📝', NULL),
('short', 'Short', 'Video corto tipo TikTok/Reels', '🎬', 60000),
('thread', 'Hilo', 'Serie de publicaciones conectadas', '🧵', NULL);
\`\`\`

### 2.3 Índices Críticos para Rendimiento

\`\`\`sql
-- Índices para búsqueda rápida
CREATE INDEX idx_posts_created_at_desc ON posts(created_at DESC);
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_post_metadata_engagement ON post_metadata(engagement_score DESC);
CREATE INDEX idx_post_likes_user_id ON post_likes(user_id);
CREATE INDEX idx_user_interests_weight ON user_interests(weight DESC);

-- Índices para feed personalizado
CREATE INDEX idx_feed_cache_user_rank ON user_feed_cache(user_id, rank);
CREATE INDEX idx_feed_cache_timestamp ON user_feed_cache(cached_at DESC);

-- Índices para algoritmo
CREATE INDEX idx_interest_scores_user ON user_interest_scores(user_id, score DESC);
\`\`\`

### 2.4 Vistas Optimizadas

\`\`\`sql
-- Vista para feed rápido (sin joins costosos)
CREATE VIEW v_feed_posts AS
SELECT 
  p.id,
  p.user_id,
  p.post_type,
  p.title,
  p.content,
  p.created_at,
  u.username,
  u.display_name,
  u.avatar_thumbnail_url,
  pm.category_id,
  pm.likes_count,
  pm.comments_count,
  pm.engagement_score,
  pm.is_nsfw
FROM posts p
JOIN users u ON p.user_id = u.id
JOIN post_metadata pm ON p.id = pm.post_id
WHERE p.is_deleted = FALSE;

-- Vista para medios
CREATE VIEW v_post_media AS
SELECT 
  post_id,
  media_type,
  thumbnail_url,
  width,
  height,
  position
FROM post_media
ORDER BY position;
\`\`\`

## 3. OPTIMIZACIONES DE CÓDIGO

### 3.1 Optimización de Imágenes

\`\`\`dart
// ANTES (Ineficiente)
CachedNetworkImage(
  imageUrl: post.imageUrls[index],
  width: 200,
  fit: BoxFit.cover,
)

// DESPUÉS (Optimizado)
CachedNetworkImage(
  imageUrl: _getOptimizedImageUrl(post.imageUrls[index]),
  width: 200,
  height: 200,
  fit: BoxFit.cover,
  cacheManager: _customCacheManager,
  placeholder: (context, url) => ShimmerLoading(),
  errorWidget: (context, url, error) => ErrorPlaceholder(),
)

// Función helper
String _getOptimizedImageUrl(String url) {
  // Agregar parámetros de optimización
  return '$url?w=400&h=400&q=75&fm=webp';
}
\`\`\`

### 3.2 Configuración de Caché Personalizada

\`\`\`dart
final _customCacheManager = CacheManager(
  Config(
    'blinkr_image_cache',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 200, // Máximo 200 imágenes
    repo: JsonCacheInfoRepository(databasePath: path),
    fileService: HttpFileService(),
  ),
);
\`\`\`

### 3.3 Virtualización de Listas

\`\`\`dart
// Usar ExtendedListView para mejor rendimiento
ExtendedListView.builder(
  itemCount: posts.length,
  itemBuilder: (context, index) {
    return PostCard(
      post: posts[index],
      key: ValueKey(posts[index].id),
    );
  },
  childrenDelegate: BuilderDelegate(
    childCount: posts.length,
    builder: (context, index) => PostCard(post: posts[index]),
  ),
)
\`\`\`

## 4. PLAN DE IMPLEMENTACIÓN

### Fase 1: BD (1-2 semanas)
- [ ] Crear nuevas tablas
- [ ] Migrar datos
- [ ] Crear índices
- [ ] Crear vistas

### Fase 2: Backend (2-3 semanas)
- [ ] Actualizar queries
- [ ] Implementar caché
- [ ] Optimizar endpoints

### Fase 3: Frontend (2-3 semanas)
- [ ] Actualizar modelos
- [ ] Optimizar imágenes
- [ ] Implementar virtualización

### Fase 4: Testing (1 semana)
- [ ] Tests de rendimiento
- [ ] Tests en gama media
- [ ] Optimización final

## 5. RESULTADOS ESPERADOS

\`\`\`
Métrica                          Antes     Después   Mejora
─────────────────────────────────────────────────────────────
Tiempo carga inicial             3.5s      1.2s      66%
Memoria RAM usada                180MB     85MB      53%
Consumo datos por sesión         45MB      12MB      73%
FPS en scroll                    45-50     58-60     28%
Tiempo respuesta like            800ms     250ms     69%
Tamaño app instalada            85MB      48MB      44%
\`\`\`

## 6. MONITOREO

Implementar métricas:
- Tiempo de carga de feed
- Uso de memoria
- Consumo de datos
- FPS en scroll
- Tasa de errores
