-- ============================================================================
-- BLINKR DATABASE MIGRATION V2 - OPTIMIZACIÓN PARA GAMA MEDIA
-- ============================================================================
-- Este script crea las nuevas tablas optimizadas para mejor rendimiento
-- Ejecutar después de hacer backup de datos actuales

-- 1. TABLA DE TIPOS DE CONTENIDO
CREATE TABLE IF NOT EXISTS post_types (
  id VARCHAR(10) PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  description TEXT,
  icon VARCHAR(10),
  max_duration_ms INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO post_types (id, name, description, icon, max_duration_ms) VALUES
('post', 'Publicación', 'Publicación estándar con texto e imágenes', '📝', NULL),
('short', 'Short', 'Video corto tipo TikTok/Reels', '🎬', 60000),
('thread', 'Hilo', 'Serie de publicaciones conectadas', '🧵', NULL)
ON CONFLICT (id) DO NOTHING;

-- 2. TABLA POSTS OPTIMIZADA
CREATE TABLE IF NOT EXISTS posts_v2 (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  post_type VARCHAR(10) NOT NULL DEFAULT 'post' REFERENCES post_types(id),
  title VARCHAR(200),
  content TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_deleted BOOLEAN DEFAULT FALSE,
  
  -- Índices
  CONSTRAINT posts_v2_pkey PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_posts_v2_user_id ON posts_v2(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_v2_created_at ON posts_v2(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_v2_post_type ON posts_v2(post_type);
CREATE INDEX IF NOT EXISTS idx_posts_v2_not_deleted ON posts_v2(is_deleted) WHERE is_deleted = FALSE;

-- 3. TABLA DE METADATOS (Separada para optimización)
CREATE TABLE IF NOT EXISTS post_metadata_v2 (
  post_id UUID PRIMARY KEY REFERENCES posts_v2(id) ON DELETE CASCADE,
  category_id VARCHAR(50),
  is_nsfw BOOLEAN DEFAULT FALSE,
  nsfw_warning VARCHAR(200),
  likes_count INT DEFAULT 0,
  comments_count INT DEFAULT 0,
  shares_count INT DEFAULT 0,
  views_count INT DEFAULT 0,
  engagement_score FLOAT DEFAULT 0,
  cached_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  CONSTRAINT post_metadata_v2_pkey PRIMARY KEY (post_id)
);

CREATE INDEX IF NOT EXISTS idx_post_metadata_v2_category ON post_metadata_v2(category_id);
CREATE INDEX IF NOT EXISTS idx_post_metadata_v2_engagement ON post_metadata_v2(engagement_score DESC);
CREATE INDEX IF NOT EXISTS idx_post_metadata_v2_nsfw ON post_metadata_v2(is_nsfw);

-- 4. TABLA DE MEDIOS (Separada)
CREATE TABLE IF NOT EXISTS post_media_v2 (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES posts_v2(id) ON DELETE CASCADE,
  media_type VARCHAR(20) NOT NULL, -- 'image', 'video', 'gif'
  url VARCHAR(500) NOT NULL,
  thumbnail_url VARCHAR(500),
  width INT,
  height INT,
  size_bytes INT,
  duration_ms INT,
  position INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_post_media_v2_post_id ON post_media_v2(post_id);
CREATE INDEX IF NOT EXISTS idx_post_media_v2_media_type ON post_media_v2(media_type);
CREATE INDEX IF NOT EXISTS idx_post_media_v2_position ON post_media_v2(post_id, position);

-- 5. TABLA DE USUARIOS OPTIMIZADA
CREATE TABLE IF NOT EXISTS users_v2 (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username VARCHAR(50) UNIQUE NOT NULL,
  display_name VARCHAR(100),
  avatar_url VARCHAR(500),
  avatar_thumbnail_url VARCHAR(500),
  bio TEXT,
  followers_count INT DEFAULT 0,
  following_count INT DEFAULT 0,
  posts_count INT DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_v2_username ON users_v2(username);
CREATE INDEX IF NOT EXISTS idx_users_v2_followers ON users_v2(followers_count DESC);

-- 6. TABLA DE INTERESES DEL USUARIO (Reemplaza interest_selections)
CREATE TABLE IF NOT EXISTS user_interests_v2 (
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  interest_id VARCHAR(50) NOT NULL,
  weight FLOAT DEFAULT 1.0,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  PRIMARY KEY (user_id, interest_id)
);

CREATE INDEX IF NOT EXISTS idx_user_interests_v2_user_id ON user_interests_v2(user_id);
CREATE INDEX IF NOT EXISTS idx_user_interests_v2_weight ON user_interests_v2(weight DESC);

-- 7. TABLA DE LIKES (Para algoritmo de aprendizaje)
CREATE TABLE IF NOT EXISTS post_likes_v2 (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts_v2(id) ON DELETE CASCADE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(user_id, post_id)
);

CREATE INDEX IF NOT EXISTS idx_post_likes_v2_user_id ON post_likes_v2(user_id);
CREATE INDEX IF NOT EXISTS idx_post_likes_v2_post_id ON post_likes_v2(post_id);
CREATE INDEX IF NOT EXISTS idx_post_likes_v2_created_at ON post_likes_v2(created_at DESC);

-- 8. TABLA DE PUNTUACIONES DE INTERESES (Algoritmo)
CREATE TABLE IF NOT EXISTS user_interest_scores_v2 (
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  interest_id VARCHAR(50) NOT NULL,
  score FLOAT DEFAULT 0,
  likes_count INT DEFAULT 0,
  views_count INT DEFAULT 0,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  PRIMARY KEY (user_id, interest_id)
);

CREATE INDEX IF NOT EXISTS idx_user_interest_scores_v2_score ON user_interest_scores_v2(user_id, score DESC);

-- 9. TABLA DE CACHÉ DE FEED
CREATE TABLE IF NOT EXISTS user_feed_cache_v2 (
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts_v2(id) ON DELETE CASCADE,
  rank INT NOT NULL,
  score FLOAT NOT NULL,
  cached_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  PRIMARY KEY (user_id, post_id)
);

CREATE INDEX IF NOT EXISTS idx_user_feed_cache_v2_rank ON user_feed_cache_v2(user_id, rank);
CREATE INDEX IF NOT EXISTS idx_user_feed_cache_v2_timestamp ON user_feed_cache_v2(cached_at DESC);

-- 10. VISTAS OPTIMIZADAS
CREATE OR REPLACE VIEW v_feed_posts_optimized AS
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
  pm.is_nsfw,
  pm.nsfw_warning
FROM posts_v2 p
JOIN users_v2 u ON p.user_id = u.id
JOIN post_metadata_v2 pm ON p.id = pm.post_id
WHERE p.is_deleted = FALSE
ORDER BY p.created_at DESC;

-- 11. FUNCIÓN PARA ACTUALIZAR ENGAGEMENT SCORE
CREATE OR REPLACE FUNCTION update_engagement_score(post_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE post_metadata_v2
  SET engagement_score = (
    (likes_count * 1.0) + 
    (comments_count * 2.0) + 
    (shares_count * 3.0) +
    (views_count * 0.1)
  ) / 10.0
  WHERE post_id = post_id;
END;
$$ LANGUAGE plpgsql;

-- 12. FUNCIÓN PARA ACTUALIZAR PUNTUACIONES DE INTERESES
CREATE OR REPLACE FUNCTION update_user_interest_score(
  p_user_id UUID,
  p_interest_id VARCHAR(50)
)
RETURNS VOID AS $$
BEGIN
  INSERT INTO user_interest_scores_v2 (user_id, interest_id, score, likes_count)
  SELECT 
    p_user_id,
    p_interest_id,
    COUNT(*) * 1.5,
    COUNT(*)
  FROM post_likes_v2 pl
  JOIN posts_v2 p ON pl.post_id = p.id
  JOIN post_metadata_v2 pm ON p.id = pm.post_id
  WHERE pl.user_id = p_user_id AND pm.category_id = p_interest_id
  ON CONFLICT (user_id, interest_id) DO UPDATE
  SET score = EXCLUDED.score, likes_count = EXCLUDED.likes_count;
END;
$$ LANGUAGE plpgsql;

-- 13. TRIGGERS PARA MANTENER CONTEOS ACTUALIZADOS
CREATE OR REPLACE FUNCTION update_post_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE post_metadata_v2
  SET likes_count = (SELECT COUNT(*) FROM post_likes_v2 WHERE post_id = NEW.post_id)
  WHERE post_id = NEW.post_id;
  
  PERFORM update_engagement_score(NEW.post_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_likes_count
AFTER INSERT OR DELETE ON post_likes_v2
FOR EACH ROW
EXECUTE FUNCTION update_post_likes_count();

-- 14. COMENTARIOS SOBRE MIGRACIÓN
-- Para migrar datos de las tablas antiguas:
-- INSERT INTO posts_v2 SELECT * FROM posts;
-- INSERT INTO post_metadata_v2 SELECT * FROM post_metadata;
-- etc.
