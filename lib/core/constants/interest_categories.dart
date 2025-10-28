class InterestCategory {
  final String id;
  final String name;
  final String icon;
  final bool isNSFW;
  final String description;

  const InterestCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.isNSFW = false,
    required this.description,
  });
  
  // Getter para compatibilidad con código que usa isNsfw (minúscula)
  bool get isNsfw => isNSFW;
}

class InterestCategories {
  // All 58 interest categories as specified
  static const List<InterestCategory> all = [
    // General Interests
    InterestCategory(
      id: 'music',
      name: 'Música',
      icon: '🎵',
      description: 'Comparte y descubre música',
    ),
    InterestCategory(
      id: 'movies',
      name: 'Cine',
      icon: '🎬',
      description: 'Películas y series',
    ),
    InterestCategory(
      id: 'gaming',
      name: 'Gaming',
      icon: '🎮',
      description: 'Videojuegos y esports',
    ),
    InterestCategory(
      id: 'sports',
      name: 'Deportes',
      icon: '⚽',
      description: 'Deportes y fitness',
    ),
    InterestCategory(
      id: 'travel',
      name: 'Viajes',
      icon: '✈️',
      description: 'Aventuras y destinos',
    ),
    InterestCategory(
      id: 'food',
      name: 'Gastronomía',
      icon: '🍕',
      description: 'Comida y recetas',
    ),
    InterestCategory(
      id: 'art',
      name: 'Arte',
      icon: '🎨',
      description: 'Arte y creatividad',
    ),
    InterestCategory(
      id: 'photography',
      name: 'Fotografía',
      icon: '📷',
      description: 'Fotografía y edición',
    ),
    InterestCategory(
      id: 'books',
      name: 'Libros',
      icon: '📚',
      description: 'Literatura y lectura',
    ),
    InterestCategory(
      id: 'technology',
      name: 'Tecnología',
      icon: '💻',
      description: 'Tech y gadgets',
    ),
    
    // Lifestyle
    InterestCategory(
      id: 'fashion',
      name: 'Moda',
      icon: '👗',
      description: 'Estilo y tendencias',
    ),
    InterestCategory(
      id: 'beauty',
      name: 'Belleza',
      icon: '💄',
      description: 'Makeup y skincare',
    ),
    InterestCategory(
      id: 'fitness',
      name: 'Fitness',
      icon: '💪',
      description: 'Ejercicio y salud',
    ),
    InterestCategory(
      id: 'wellness',
      name: 'Bienestar',
      icon: '🧘',
      description: 'Salud mental y física',
    ),
    InterestCategory(
      id: 'pets',
      name: 'Mascotas',
      icon: '🐾',
      description: 'Animales y cuidados',
    ),
    
    // Social & Community
    InterestCategory(
      id: 'lgbtq',
      name: 'LGBTQ+',
      icon: '🏳️‍🌈',
      description: 'Comunidad LGBTQ+',
    ),
    InterestCategory(
      id: 'activism',
      name: 'Activismo',
      icon: '✊',
      description: 'Causas sociales',
    ),
    InterestCategory(
      id: 'politics',
      name: 'Política',
      icon: '🗳️',
      description: 'Debate político',
    ),
    InterestCategory(
      id: 'environment',
      name: 'Medio Ambiente',
      icon: '🌱',
      description: 'Ecología y sostenibilidad',
    ),
    
    // Entertainment
    InterestCategory(
      id: 'anime',
      name: 'Anime',
      icon: '🎌',
      description: 'Anime y manga',
    ),
    InterestCategory(
      id: 'comics',
      name: 'Comics',
      icon: '📖',
      description: 'Comics y superhéroes',
    ),
    InterestCategory(
      id: 'memes',
      name: 'Memes',
      icon: '😂',
      description: 'Humor y memes',
    ),
    InterestCategory(
      id: 'streaming',
      name: 'Streaming',
      icon: '📺',
      description: 'Streamers y contenido',
    ),
    
    // Creative
    InterestCategory(
      id: 'music_production',
      name: 'Producción Musical',
      icon: '🎹',
      description: 'Crear música',
    ),
    InterestCategory(
      id: 'writing',
      name: 'Escritura',
      icon: '✍️',
      description: 'Escritura creativa',
    ),
    InterestCategory(
      id: 'design',
      name: 'Diseño',
      icon: '🖌️',
      description: 'Diseño gráfico y UX',
    ),
    InterestCategory(
      id: 'crafts',
      name: 'Manualidades',
      icon: '🧶',
      description: 'DIY y crafts',
    ),
    
    // Professional
    InterestCategory(
      id: 'business',
      name: 'Negocios',
      icon: '💼',
      description: 'Emprendimiento',
    ),
    InterestCategory(
      id: 'finance',
      name: 'Finanzas',
      icon: '💰',
      description: 'Inversiones y dinero',
    ),
    InterestCategory(
      id: 'career',
      name: 'Carrera',
      icon: '📈',
      description: 'Desarrollo profesional',
    ),
    InterestCategory(
      id: 'education',
      name: 'Educación',
      icon: '🎓',
      description: 'Aprendizaje',
    ),
    
    // Hobbies
    InterestCategory(
      id: 'gardening',
      name: 'Jardinería',
      icon: '🌻',
      description: 'Plantas y jardines',
    ),
    InterestCategory(
      id: 'cooking',
      name: 'Cocina',
      icon: '👨‍🍳',
      description: 'Recetas y técnicas',
    ),
    InterestCategory(
      id: 'diy',
      name: 'DIY',
      icon: '🔨',
      description: 'Hazlo tú mismo',
    ),
    InterestCategory(
      id: 'cars',
      name: 'Autos',
      icon: '🚗',
      description: 'Coches y motos',
    ),
    
    // Nightlife & Dating
    InterestCategory(
      id: 'nightlife',
      name: 'Vida Nocturna',
      icon: '🌃',
      description: 'Fiestas y eventos',
    ),
    InterestCategory(
      id: 'dating',
      name: 'Citas',
      icon: '💕',
      description: 'Dating y relaciones',
    ),
    InterestCategory(
      id: 'friendship',
      name: 'Amistad',
      icon: '🤝',
      description: 'Hacer amigos',
    ),
    InterestCategory(
      id: 'networking',
      name: 'Networking',
      icon: '🔗',
      description: 'Conexiones profesionales',
    ),
    
    // NSFW Categories (18+)
    InterestCategory(
      id: 'nsfw_general',
      name: 'Contenido Adulto',
      icon: '🔞',
      isNSFW: true,
      description: 'Contenido para adultos',
    ),
    InterestCategory(
      id: 'nsfw_art',
      name: 'Arte Erótico',
      icon: '🎨',
      isNSFW: true,
      description: 'Arte sensual y erótico',
    ),
    InterestCategory(
      id: 'nsfw_photography',
      name: 'Fotografía Sensual',
      icon: '📸',
      isNSFW: true,
      description: 'Fotografía artística adulta',
    ),
    InterestCategory(
      id: 'kink',
      name: 'Kink & Fetish',
      icon: '⛓️',
      isNSFW: true,
      description: 'Comunidad kink',
    ),
    InterestCategory(
      id: 'bdsm',
      name: 'BDSM',
      icon: '🔗',
      isNSFW: true,
      description: 'BDSM y prácticas',
    ),
    InterestCategory(
      id: 'polyamory',
      name: 'Poliamor',
      icon: '💞',
      isNSFW: true,
      description: 'Relaciones poliamorosas',
    ),
    InterestCategory(
      id: 'hookups',
      name: 'Encuentros',
      icon: '🔥',
      isNSFW: true,
      description: 'Encuentros casuales',
    ),
    
    // Spirituality & Philosophy
    InterestCategory(
      id: 'spirituality',
      name: 'Espiritualidad',
      icon: '🕉️',
      description: 'Espiritualidad y meditación',
    ),
    InterestCategory(
      id: 'philosophy',
      name: 'Filosofía',
      icon: '🤔',
      description: 'Pensamiento filosófico',
    ),
    InterestCategory(
      id: 'astrology',
      name: 'Astrología',
      icon: '♈',
      description: 'Astrología y zodíaco',
    ),
    
    // Science & Nature
    InterestCategory(
      id: 'science',
      name: 'Ciencia',
      icon: '🔬',
      description: 'Ciencia y descubrimientos',
    ),
    InterestCategory(
      id: 'nature',
      name: 'Naturaleza',
      icon: '🌲',
      description: 'Naturaleza y wildlife',
    ),
    InterestCategory(
      id: 'astronomy',
      name: 'Astronomía',
      icon: '🌌',
      description: 'Espacio y universo',
    ),
    
    // Music Genres
    InterestCategory(
      id: 'rock',
      name: 'Rock',
      icon: '🎸',
      description: 'Rock y metal',
    ),
    InterestCategory(
      id: 'electronic',
      name: 'Electrónica',
      icon: '🎧',
      description: 'Música electrónica',
    ),
    InterestCategory(
      id: 'hiphop',
      name: 'Hip Hop',
      icon: '🎤',
      description: 'Hip hop y rap',
    ),
    InterestCategory(
      id: 'indie',
      name: 'Indie',
      icon: '🎵',
      description: 'Música indie',
    ),
    InterestCategory(
      id: 'latin',
      name: 'Música Latina',
      icon: '🎺',
      description: 'Reggaeton, salsa, etc',
    ),
  ];
  
  // Getter agregado para compatibilidad
  static List<InterestCategory> get allCategories => all;
  
  static List<InterestCategory> get sfw => all.where((c) => !c.isNSFW).toList();
  static List<InterestCategory> get nsfw => all.where((c) => c.isNSFW).toList();
  
  static InterestCategory? getById(String id) {
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}