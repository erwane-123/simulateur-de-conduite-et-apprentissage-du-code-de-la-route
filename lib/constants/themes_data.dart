class ThemeData {
  static final List<Map<String, dynamic>> themes = [
    {
      'id': 'circulation',
      'icon': '🚗',
      'title': 'La signalisation routière',
      'subtitle': 'Panneaux et marquage au sol',
      'color': 0xFFFF6B6B,
    },
    {
      'id': 'panneaux',
      'icon': '🛑',
      'title': 'Tous les panneaux du Code',
      'subtitle': 'Signalisation complète',
      'color': 0xFF4ECDC4,
    },
    {
      'id': 'priorite',
      'icon': '⚠️',
      'title': 'Les règles et panneaux de priorité',
      'subtitle': 'Priorités et intersections',
      'color': 0xFFFFE66D,
    },
    {
      'id': 'intersection',
      'icon': '🚦',
      'title': 'Intersection sur la route',
      'subtitle': 'Toutes les règles à appliquer',
      'color': 0xFF95E1D3,
    },
    {
      'id': 'vitesse',
      'icon': '🏎️',
      'title': 'Les limitations de vitesse',
      'subtitle': 'Prévues par le Code en France',
      'color': 0xFFF38181,
    },
    {
      'id': 'radar',
      'icon': '🔴',
      'title': 'Fonctionnement d\'un radar',
      'subtitle': 'De contrôle routier',
      'color': 0xFFAA96DA,
    },
    {
      'id': 'changement',
      'icon': '➡️',
      'title': 'Les changements de direction',
      'subtitle': 'Règles et procédures',
      'color': 0xFFFCBF49,
    },
    {
      'id': 'croisement',
      'icon': '🚛',
      'title': 'Croisement : les distances',
      'subtitle': 'De sécurité à respecter',
      'color': 0xFF5DADE2,
    },
  ];

  static final List<Map<String, dynamic>> coursesCategories = [
    {
      'id': 'theory',
      'title': 'Cours Théoriques',
      'icon': '📚',
      'description': 'Apprendre les bases du code',
    },
    {
      'id': 'practice',
      'title': 'Exercices Pratiques',
      'icon': '✍️',
      'description': 'S\'entraîner sur des cas réels',
    },
    {
      'id': 'videos',
      'title': 'Vidéos Explicatives',
      'icon': '🎥',
      'description': 'Comprendre en images',
    },
  ];
}
