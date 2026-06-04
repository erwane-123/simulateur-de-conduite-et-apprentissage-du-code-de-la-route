import 'package:code_route_flutter/models/chapitre.dart';

class Cours {
  final String id;
  final String title;
  final String icon;
  final String description;
  final double progress;
  final int chaptersCount;
  final List<String> categories;
  final List<Chapitre> chapitres;

  Cours({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    this.progress = 0.0,
    required this.chaptersCount,
    required this.categories,
    required this.chapitres,
  });

  // Suggestion : calculer chaptersCount automatiquement au lieu de le passer manuellement
  // (plus sûr, évite les erreurs humaines)
  Cours.fromData({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    this.progress = 0.0,
    required this.categories,
    required this.chapitres,
  }) : chaptersCount = chapitres.length;

  // Version actuelle conservée pour compatibilité, mais tu peux migrer vers fromData
  static List<Cours> getAllCours() {
    return [
      // ───────────────────────────────────────────────
      // COURS 1 : SIGNALISATION ROUTIÈRE
      // ───────────────────────────────────────────────
      Cours(
        id: '1',
        title: 'La signalisation routière',
        icon: '🚧',
        description: 'Tous les panneaux et marquages',
        progress: 0.65,
        chaptersCount:
            8, // ← peut être supprimé si tu utilises le constructeur fromData
        categories: ['B', 'A', 'A1', 'C', 'D', 'BE'],
        chapitres: [
          Chapitre(
            id: '1-1',
            title: 'Les panneaux de danger',
            description: 'Panneaux triangulaires à bordure rouge',
            pdfPath: 'assets/cours/signalisation/chapitre1_signalisation.pdf',
            duration: 15,
          ),
          Chapitre(
            id: '1-2',
            title: "Les panneaux d'interdiction",
            description: 'Panneaux ronds à bordure rouge',
            pdfPath: 'assets/cours/signalisation/chapitre2_signalisation.pdf',
            duration: 20,
          ),
          Chapitre(
            id: '1-3',
            title: "Les panneaux d'obligation",
            description: 'Panneaux ronds bleus',
            pdfPath: 'assets/cours/signalisation/chapitre3_signalisation.pdf',
            duration: 12,
          ),
          Chapitre(
            id: '1-4',
            title: "Les panneaux d'indication",
            description: 'Panneaux carrés ou rectangulaires bleus',
            pdfPath: 'assets/cours/signalisation/chapitre4_signalisation.pdf',
            duration: 18,
          ),
          Chapitre(
            id: '1-5',
            title: 'Le marquage au sol',
            description: 'Lignes continues, discontinues, flèches…',
            pdfPath: 'assets/cours/signalisation/chapitre5_signalisation.pdf',
            duration: 15,
          ),
          Chapitre(
            id: '1-6',
            title: 'Les feux tricolores',
            description: 'Feux fixes, clignotants et flèches',
            pdfPath: 'assets/cours/signalisation/chapitre6_signalisation.pdf',
            duration: 10,
          ),
          Chapitre(
            id: '1-7',
            title: 'La signalisation temporaire',
            description: 'Panneaux de travaux et déviations',
            pdfPath: 'assets/cours/signalisation/chapitre7_signalisation.pdf',
            duration: 8,
          ),
          Chapitre(
            id: '1-8',
            title: 'Les gestes des agents de circulation',
            description: 'Gestes des policiers et gendarmes',
            pdfPath: 'assets/cours/signalisation/chapitre8_signalisation.pdf',
            duration: 12,
          ),
        ],
      ),

      // ───────────────────────────────────────────────
      // COURS 2 : MÉCANIQUE (exemple – tu peux continuer)
      // ───────────────────────────────────────────────
      Cours(
        id: '2',
        title: 'Mécanique et équipements',
        icon: '🔧',
        description: 'Fonctionnement et entretien du véhicule',
        progress: 0.42,
        chaptersCount: 6,
        categories: ['B', 'BE'],
        chapitres: [
          // ... tes chapitres existants ...
        ],
      ),

      // ───────────────────────────────────────────────
      // COURS 3 : PRIORITÉS
      // ───────────────────────────────────────────────
      Cours(
        id: '3',
        title: 'Les règles de priorité',
        icon: '⚠️',
        description: 'Comprendre et appliquer les priorités',
        progress: 0.78,
        chaptersCount: 3,
        categories: ['B', 'A', 'A1', 'C', 'D', 'BE'],
        chapitres: [
          // ... tes chapitres existants ...
        ],
      ),

      // TODO: Ajouter les autres cours (Éco-conduite, Premiers secours, etc.)
    ];
  }

  static List<Cours> getCoursForCategory(String? category) {
    if (category == null || category.isEmpty) {
      return getAllCours();
    }
    return getAllCours()
        .where((cours) => cours.categories.contains(category))
        .toList();
  }
}
