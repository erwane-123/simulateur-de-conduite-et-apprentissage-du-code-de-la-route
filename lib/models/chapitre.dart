class Chapitre {
  final String id;
  final String title;
  final String description;
  final String pdfPath;
  final int duration;
  final bool isCompleted;

  Chapitre({
    required this.id,
    required this.title,
    required this.description,
    required this.pdfPath,
    this.duration = 10,
    this.isCompleted = false,
  });
}
