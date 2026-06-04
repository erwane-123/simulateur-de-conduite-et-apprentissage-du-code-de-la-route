class ThemeModel {
  final String id;
  final String icon;
  final String title;
  final String subtitle;
  final int color;
  final double progress;
  final int totalQuestions;
  final int answeredQuestions;

  ThemeModel({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.progress = 0.0,
    this.totalQuestions = 0,
    this.answeredQuestions = 0,
  });

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      id: json['id'] ?? '',
      icon: json['icon'] ?? '📚',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      color: json['color'] ?? 0xFF667EEA,
      progress: (json['progress'] ?? 0.0).toDouble(),
      totalQuestions: json['totalQuestions'] ?? 0,
      answeredQuestions: json['answeredQuestions'] ?? 0,
    );
  }
}
