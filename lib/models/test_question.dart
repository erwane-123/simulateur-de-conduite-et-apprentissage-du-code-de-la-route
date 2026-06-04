enum QuestionType {
  multipleChoice,
  typedAnswer,
  reorder,
  fillBlank,
}

QuestionType questionTypeFromString(String? value) {
  switch (value) {
    case 'typedAnswer':
      return QuestionType.typedAnswer;
    case 'reorder':
      return QuestionType.reorder;
    case 'fillBlank':
      return QuestionType.fillBlank;
    case 'multipleChoice':
    default:
      return QuestionType.multipleChoice;
  }
}

String questionTypeToString(QuestionType value) {
  switch (value) {
    case QuestionType.typedAnswer:
      return 'typedAnswer';
    case QuestionType.reorder:
      return 'reorder';
    case QuestionType.fillBlank:
      return 'fillBlank';
    case QuestionType.multipleChoice:
      return 'multipleChoice';
  }
}

class TestQuestion {
  final int id;
  final String permitCode;
  final String themeId;
  final String question;
  final String imagePath;
  final String fallbackImagePath;
  final List<Answer> answers;
  final QuestionType type;
  final List<String> reorderItems;
  final String? fillBlankSentence;
  final List<String> acceptedAnswers;
  final List<String> tags;
  final String? explanation;
  final String? officialLink;

  TestQuestion({
    required this.id,
    this.permitCode = 'B',
    required this.themeId,
    required this.question,
    required this.imagePath,
    required this.fallbackImagePath,
    required this.answers,
    this.type = QuestionType.multipleChoice,
    this.reorderItems = const [],
    this.fillBlankSentence,
    this.acceptedAnswers = const [],
    this.tags = const [],
    this.explanation,
    this.officialLink,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'permitCode': permitCode,
      'themeId': themeId,
      'question': question,
      'imagePath': imagePath,
      'fallbackImagePath': fallbackImagePath,
      'answers': answers.map((x) => x.toMap()).toList(),
      'type': questionTypeToString(type),
      'reorderItems': reorderItems,
      'fillBlankSentence': fillBlankSentence,
      'acceptedAnswers': acceptedAnswers,
      'tags': tags,
      'explanation': explanation,
      'officialLink': officialLink,
    };
  }

  factory TestQuestion.fromMap(Map<String, dynamic> map) {
    return TestQuestion(
      id: map['id']?.toInt() ?? 0,
      permitCode: map['permitCode'] ?? 'B',
      themeId: map['themeId'] ?? '',
      question: map['question'] ?? '',
      imagePath: map['imagePath'] ?? '',
      fallbackImagePath: map['fallbackImagePath'] ?? '',
      answers: List<Answer>.from(
          (map['answers'] ?? []).map((x) => Answer.fromMap(x))),
      type: questionTypeFromString(map['type']),
      reorderItems: List<String>.from(map['reorderItems'] ?? []),
      fillBlankSentence: map['fillBlankSentence'],
      acceptedAnswers: List<String>.from(map['acceptedAnswers'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      explanation: map['explanation'],
      officialLink: map['officialLink'],
    );
  }

  TestQuestion copyWith({
    int? id,
    String? permitCode,
    String? themeId,
    String? question,
    String? imagePath,
    String? fallbackImagePath,
    List<Answer>? answers,
    QuestionType? type,
    List<String>? reorderItems,
    String? fillBlankSentence,
    List<String>? acceptedAnswers,
    List<String>? tags,
    String? explanation,
    String? officialLink,
  }) {
    return TestQuestion(
      id: id ?? this.id,
      permitCode: permitCode ?? this.permitCode,
      themeId: themeId ?? this.themeId,
      question: question ?? this.question,
      imagePath: imagePath ?? this.imagePath,
      fallbackImagePath: fallbackImagePath ?? this.fallbackImagePath,
      answers: answers ?? this.answers,
      type: type ?? this.type,
      reorderItems: reorderItems ?? this.reorderItems,
      fillBlankSentence: fillBlankSentence ?? this.fillBlankSentence,
      acceptedAnswers: acceptedAnswers ?? this.acceptedAnswers,
      tags: tags ?? this.tags,
      explanation: explanation ?? this.explanation,
      officialLink: officialLink ?? this.officialLink,
    );
  }
}

class Answer {
  final String text;
  final bool isCorrect;

  Answer({required this.text, required this.isCorrect});

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isCorrect': isCorrect,
    };
  }

  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      text: map['text'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
    );
  }
}
