class TestQuestion {
  final int id;
  final String question;
  final String imagePath;
  final List<Answer> answers;
  final String? themeId;
  final String? category;
  final List<String> tags;
  final String? explanation;
  final String? officialLink;

  TestQuestion({
    required this.id,
    required this.question,
    required this.imagePath,
    required this.answers,
    this.themeId,
    this.category,
    this.tags = const [],
    this.explanation,
    this.officialLink,
  });
}

class Answer {
  final String text;
  final bool isCorrect;

  Answer({required this.text, required this.isCorrect});
}
