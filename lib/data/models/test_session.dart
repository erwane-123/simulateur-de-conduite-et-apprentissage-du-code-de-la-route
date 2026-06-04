import 'package:code_route_flutter/models/test_question.dart';

class TestSession {
  final String id;
  final DateTime startTime;
  final List<TestQuestion> questions;
  final Map<int, bool> answers;
  int currentQuestionIndex;
  int score;

  TestSession({
    required this.id,
    required this.startTime,
    required this.questions,
    this.currentQuestionIndex = 0,
    this.score = 0,
    Map<int, bool>? answers,
  }) : answers = answers ?? {};

  bool answerQuestion(int questionId, bool isCorrect) {
    answers[questionId] = isCorrect;
    if (isCorrect) {
      score++;
    }
    return isCorrect;
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
    }
  }

  bool isCompleted() {
    return currentQuestionIndex >= questions.length - 1;
  }

  double getPercentage() {
    return (score / questions.length) * 100;
  }

  bool hasPassed() {
    return score >= 35; // 35/40 pour réussir
  }

  TestQuestion getCurrentQuestion() {
    return questions[currentQuestionIndex];
  }
}
