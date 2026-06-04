class ThemeCode {
  final String id;
  final String name;
  final String icon;
  final double progress;
  final int questionsTotal;
  final int questionsAnswered;

  ThemeCode({
    required this.id,
    required this.name,
    required this.icon,
    this.progress = 0.0,
    required this.questionsTotal,
    this.questionsAnswered = 0,
  });

  static List<ThemeCode> getAllThemes() {
    return [
      ThemeCode(id: '1', name: 'Circulation routière', icon: '🚗', progress: 0.0, questionsTotal: 120, questionsAnswered: 0),
      ThemeCode(id: '2', name: 'Le conducteur', icon: '🧑', progress: 0.0, questionsTotal: 100, questionsAnswered: 0),
      ThemeCode(id: '3', name: 'La route', icon: '🛣️', progress: 0.0, questionsTotal: 90, questionsAnswered: 0),
      ThemeCode(id: '4', name: 'Les autres usagers', icon: '🚶', progress: 0.0, questionsTotal: 80, questionsAnswered: 0),
      ThemeCode(id: '5', name: 'Notions diverses', icon: '📋', progress: 0.0, questionsTotal: 85, questionsAnswered: 0),
      ThemeCode(id: '6', name: 'Premiers secours', icon: '🚑', progress: 0.0, questionsTotal: 70, questionsAnswered: 0),
      ThemeCode(id: '7', name: 'Prendre et quitter son véhicule', icon: '🚪', progress: 0.0, questionsTotal: 60, questionsAnswered: 0),
      ThemeCode(id: '8', name: 'Mécanique et équipements', icon: '🔧', progress: 0.0, questionsTotal: 95, questionsAnswered: 0),
      ThemeCode(id: '9', name: 'Sécurité du passager', icon: '👨‍👩‍👧', progress: 0.0, questionsTotal: 75, questionsAnswered: 0),
      ThemeCode(id: '10', name: 'Environnement', icon: '🌱', progress: 0.0, questionsTotal: 80, questionsAnswered: 0),
    ];
  }
}
