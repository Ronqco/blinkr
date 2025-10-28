-- Seed all 58 interest categories
INSERT INTO interest_categories (id, name, icon, is_nsfw, description) VALUES
-- General Interests
('music', 'Música', '🎵', false, 'Comparte y descubre música'),
('movies', 'Cine', '🎬', false, 'Películas y series'),
('gaming', 'Gaming', '🎮', false, 'Videojuegos y esports'),
('sports', 'Deportes', '⚽', false, 'Deportes y fitness'),
('travel', 'Viajes', '✈️', false, 'Aventuras y destinos'),
('food', 'Gastronomía', '🍕', false, 'Comida y recetas'),
('art', 'Arte', '🎨', false, 'Arte y creatividad'),
('photography', 'Fotografía', '📷', false, 'Fotografía y edición'),
('books', 'Libros', '📚', false, 'Literatura y lectura'),
('technology', 'Tecnología', '💻', false, 'Tech y gadgets'),

-- Lifestyle
('fashion', 'Moda', '👗', false, 'Estilo y tendencias'),
('beauty', 'Belleza', '💄', false, 'Makeup y skincare'),
('fitness', 'Fitness', '💪', false, 'Ejercicio y salud'),
('wellness', 'Bienestar', '🧘', false, 'Salud mental y física'),
('pets', 'Mascotas', '🐾', false, 'Animales y cuidados'),

-- Social & Community
('lgbtq', 'LGBTQ+', '🏳️‍🌈', false, 'Comunidad LGBTQ+'),
('activism', 'Activismo', '✊', false, 'Causas sociales'),
('politics', 'Política', '🗳️', false, 'Debate político'),
('environment', 'Medio Ambiente', '🌱', false, 'Ecología y sostenibilidad'),

-- Entertainment
('anime', 'Anime', '🎌', false, 'Anime y manga'),
('comics', 'Comics', '📖', false, 'Comics y superhéroes'),
('memes', 'Memes', '😂', false, 'Humor y memes'),
('streaming', 'Streaming', '📺', false, 'Streamers y contenido'),

-- Creative
('music_production', 'Producción Musical', '🎹', false, 'Crear música'),
('writing', 'Escritura', '✍️', false, 'Escritura creativa'),
('design', 'Diseño', '🖌️', false, 'Diseño gráfico y UX'),
('crafts', 'Manualidades', '🧶', false, 'DIY y crafts'),

-- Professional
('business', 'Negocios', '💼', false, 'Emprendimiento'),
('finance', 'Finanzas', '💰', false, 'Inversiones y dinero'),
('career', 'Carrera', '📈', false, 'Desarrollo profesional'),
('education', 'Educación', '🎓', false, 'Aprendizaje'),

-- Hobbies
('gardening', 'Jardinería', '🌻', false, 'Plantas y jardines'),
('cooking', 'Cocina', '👨‍🍳', false, 'Recetas y técnicas'),
('diy', 'DIY', '🔨', false, 'Hazlo tú mismo'),
('cars', 'Autos', '🚗', false, 'Coches y motos'),

-- Nightlife & Dating
('nightlife', 'Vida Nocturna', '🌃', false, 'Fiestas y eventos'),
('dating', 'Citas', '💕', false, 'Dating y relaciones'),
('friendship', 'Amistad', '🤝', false, 'Hacer amigos'),
('networking', 'Networking', '🔗', false, 'Conexiones profesionales'),

-- NSFW Categories (18+)
('nsfw_general', 'Contenido Adulto', '🔞', true, 'Contenido para adultos'),
('nsfw_art', 'Arte Erótico', '🎨', true, 'Arte sensual y erótico'),
('nsfw_photography', 'Fotografía Sensual', '📸', true, 'Fotografía artística adulta'),
('kink', 'Kink & Fetish', '⛓️', true, 'Comunidad kink'),
('bdsm', 'BDSM', '🔗', true, 'BDSM y prácticas'),
('polyamory', 'Poliamor', '💞', true, 'Relaciones poliamorosas'),
('hookups', 'Encuentros', '🔥', true, 'Encuentros casuales'),

-- Spirituality & Philosophy
('spirituality', 'Espiritualidad', '🕉️', false, 'Espiritualidad y meditación'),
('philosophy', 'Filosofía', '🤔', false, 'Pensamiento filosófico'),
('astrology', 'Astrología', '♈', false, 'Astrología y zodíaco'),

-- Science & Nature
('science', 'Ciencia', '🔬', false, 'Ciencia y descubrimientos'),
('nature', 'Naturaleza', '🌲', false, 'Naturaleza y wildlife'),
('astronomy', 'Astronomía', '🌌', false, 'Espacio y universo'),

-- Music Genres
('rock', 'Rock', '🎸', false, 'Rock y metal'),
('electronic', 'Electrónica', '🎧', false, 'Música electrónica'),
('hiphop', 'Hip Hop', '🎤', false, 'Hip hop y rap'),
('indie', 'Indie', '🎵', false, 'Música indie'),
('latin', 'Música Latina', '🎺', false, 'Reggaeton, salsa, etc');
