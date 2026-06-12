import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:code_route_flutter/data/permit_question_bank.dart';
import 'package:code_route_flutter/data/test_questions.dart'
    as legacy_questions;
import 'package:code_route_flutter/models/test_question.dart';
import 'package:code_route_flutter/services/firebase/firestore_service.dart';
import 'package:code_route_flutter/services/user_progress_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:code_route_flutter/widgets/coach_dialog.dart';

enum QuestionInteractionStyle {
  multipleChoice,
  typedAnswer,
  reorder,
  fillBlank,
}

class TestScreen extends StatefulWidget {
  final int questionCount;
  final int timePerQuestion;
  final int requiredScore;
  final bool failOnMistake;
  final String? challengeTitle;
  final bool isSignsOnly;
  final bool isPriorityOnly;
  final String? themeIdFilter;
  final int? seriesIndex;

  const TestScreen({
    Key? key,
    this.questionCount = 40,
    this.timePerQuestion = 10,
    this.requiredScore = 35,
    this.failOnMistake = false,
    this.challengeTitle,
    this.isSignsOnly = false,
    this.isPriorityOnly = false,
    this.themeIdFilter,
    this.seriesIndex,
  }) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _firestoreService = FirestoreService();
  final _progressService = UserProgressService();

  late FlutterTts _flutterTts;
  List<TestQuestion> _questions = const [];
  String _selectedPermitCode = 'B';

  int _questionIndex = 0;
  int _score = 0;
  int _timeLeft = 10;
  bool _isLoadingQuestions = true;
  int _correctStreak = 0;

  Timer? _timer;
  final TextEditingController _typedAnswerController = TextEditingController();
  final FocusNode _typedAnswerFocusNode = FocusNode();
  List<String> _currentReorderItems = const [];

  bool get _isThemeRevision => widget.themeIdFilter != null;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadQuestions();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('fr-FR');
    await _flutterTts.setSpeechRate(kIsWeb ? 1.0 : 0.5);
  }

  List<TestQuestion> _localQuestionsForTheme(String permit, String themeId) {
    final permitQuestions = PermitQuestionBank.getQuestionsForPermit(permit)
        .where((q) => q.themeId == themeId)
        .map((q) => q.copyWith(permitCode: permit))
        .toList();

    final legacyQuestions = legacy_questions
        .getTestQuestions()
        .where((q) => q.themeId == themeId)
        .map((q) => q.copyWith(permitCode: permit))
        .toList();

    return _mergeQuestions(permitQuestions, legacyQuestions);
  }

  List<TestQuestion> _mergeQuestions(
    List<TestQuestion> primary,
    List<TestQuestion> secondary,
  ) {
    final seenIds = <int>{};
    final merged = <TestQuestion>[];

    for (final question in [...primary, ...secondary]) {
      if (seenIds.add(question.id)) {
        merged.add(question);
      }
    }

    return merged;
  }

  List<TestQuestion> _expandThemeSession(
    List<TestQuestion> questions,
    int minimumCount,
  ) {
    if (questions.isEmpty) return questions;

    final expanded = <TestQuestion>[...questions];
    var index = 0;

    while (expanded.length < minimumCount) {
      final source = questions[index % questions.length];
      expanded.add(
        source.copyWith(
          id: source.id +
              (100000 * ((expanded.length ~/ questions.length) + 1)),
          answers: source.answers
              .map((answer) => Answer(
                    text: answer.text,
                    isCorrect: answer.isCorrect,
                  ))
              .toList(),
        ),
      );
      index++;
    }

    return expanded;
  }

  List<TestQuestion> _buildAdaptiveThemeSession(List<TestQuestion> questions) {
    final easy = <TestQuestion>[];
    final medium = <TestQuestion>[];
    final hard = <TestQuestion>[];

    for (final question in questions) {
      final difficulty = _estimateQuestionDifficulty(question);
      if (difficulty == 1) {
        easy.add(question);
      } else if (difficulty == 2) {
        medium.add(question);
      } else {
        hard.add(question);
      }
    }

    easy.shuffle();
    medium.shuffle();
    hard.shuffle();
    return [...easy, ...medium, ...hard];
  }

  int _estimateQuestionDifficulty(TestQuestion question) {
    var weight = 0;
    weight += question.question.length > 70 ? 1 : 0;
    weight += question.answers.length >= 4 ? 1 : 0;
    weight += question.explanation != null && question.explanation!.length > 90
        ? 1
        : 0;
    weight += question.id % 5 == 0 ? 1 : 0;

    if (weight <= 1) return 1;
    if (weight <= 3) return 2;
    return 3;
  }

  int get _adaptiveDifficultyLevel {
    if (!_isThemeRevision) return 1;
    if (_correctStreak >= 5 || _score >= 12) return 3;
    if (_correctStreak >= 2 || _score >= 6) return 2;
    return 1;
  }

  String get _difficultyLabel {
    switch (_adaptiveDifficultyLevel) {
      case 1:
        return 'Niveau facile';
      case 2:
        return 'Niveau moyen';
      default:
        return 'Niveau difficile';
    }
  }

  Color get _difficultyColor {
    switch (_adaptiveDifficultyLevel) {
      case 1:
        return AppColors.success;
      case 2:
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }

  QuestionInteractionStyle _interactionStyleForCurrentQuestion(
      TestQuestion question) {
    if (question.type != QuestionType.multipleChoice) {
      return _styleFromQuestionType(question.type);
    }

    if (widget.seriesIndex != null) {
      switch ((_questionIndex + 1) % 4) {
        case 1:
          return QuestionInteractionStyle.multipleChoice;
        case 2:
          return QuestionInteractionStyle.typedAnswer;
        case 3:
          return QuestionInteractionStyle.reorder;
        default:
          return QuestionInteractionStyle.fillBlank;
      }
    }

    if (!_isThemeRevision) return QuestionInteractionStyle.multipleChoice;
    final difficulty = _adaptiveDifficultyLevel;

    if (difficulty == 1) {
      return QuestionInteractionStyle.multipleChoice;
    }

    final shouldAskTypedAnswer =
        difficulty == 3 || ((_questionIndex + question.id) % 3 == 0);
    return shouldAskTypedAnswer
        ? QuestionInteractionStyle.typedAnswer
        : QuestionInteractionStyle.multipleChoice;
  }

  QuestionInteractionStyle _styleFromQuestionType(QuestionType type) {
    switch (type) {
      case QuestionType.typedAnswer:
        return QuestionInteractionStyle.typedAnswer;
      case QuestionType.reorder:
        return QuestionInteractionStyle.reorder;
      case QuestionType.fillBlank:
        return QuestionInteractionStyle.fillBlank;
      case QuestionType.multipleChoice:
        return QuestionInteractionStyle.multipleChoice;
    }
  }

  Future<void> _loadQuestions() async {
    final permit = await _progressService.getSelectedPermitCode();
    List<TestQuestion> allQuestions = [];

    try {
      if (widget.themeIdFilter != null) {
        allQuestions =
            await _firestoreService.getQuestionsByTheme(widget.themeIdFilter!);
      }
    } catch (_) {
      allQuestions = [];
    }

    if (widget.themeIdFilter != null) {
      allQuestions = _mergeQuestions(
        allQuestions
            .where((q) => q.themeId == widget.themeIdFilter)
            .map((q) => q.copyWith(permitCode: permit))
            .toList(),
        _localQuestionsForTheme(permit, widget.themeIdFilter!),
      );
    } else {
      if (allQuestions.isEmpty) {
        allQuestions = PermitQuestionBank.getQuestionsForPermit(permit);
      }

      if (allQuestions.isEmpty) {
        allQuestions = legacy_questions
            .getTestQuestions()
            .map((q) => q.copyWith(permitCode: permit))
            .toList();
      }
    }

    if (widget.isSignsOnly) {
      allQuestions =
          allQuestions.where((q) => q.tags.contains('signs')).toList();
    } else if (widget.isPriorityOnly) {
      allQuestions =
          allQuestions.where((q) => q.tags.contains('priority')).toList();
    }

    if (widget.seriesIndex != null) {
      final startIndex = (widget.seriesIndex! - 1) * widget.questionCount;
      if (startIndex < allQuestions.length) {
        _questions =
            allQuestions.skip(startIndex).take(widget.questionCount).toList();
      } else {
        _questions = allQuestions.reversed.take(widget.questionCount).toList();
      }
      _questions.shuffle();
    } else if (_isThemeRevision) {
      if (allQuestions.length < widget.questionCount) {
        allQuestions = _expandThemeSession(allQuestions, widget.questionCount);
      }
      _questions = _buildAdaptiveThemeSession(allQuestions)
          .take(widget.questionCount)
          .toList();
    } else {
      allQuestions.shuffle();
      _questions = allQuestions.take(widget.questionCount).toList();
    }

    for (final q in _questions) {
      q.answers.shuffle();
    }

    if (!mounted) return;
    setState(() {
      _selectedPermitCode = permit.toUpperCase();
      _isLoadingQuestions = false;
    });

    await CoachDialog.show(
      context,
      tts: _flutterTts,
      type: CoachDialogType.intro,
    );

    if (!mounted) return;
    _startTimer();
    _speakQuestion();
  }

  void _startTimer() {
    _timeLeft = widget.timePerQuestion;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
      });

      if (_timeLeft <= 0) {
        _nextQuestion();
      }
    });
  }

  Future<void> _speakQuestion() async {
    await _flutterTts.stop();
    if (_questions.isEmpty || _questionIndex >= _questions.length) return;
    await _flutterTts.speak(_questions[_questionIndex].question);
  }

  Future<void> _answerQuestion(bool correct,
      {String? selectedAnswerText}) async {
    _timer?.cancel();

    if (correct) {
      setState(() {
        _correctStreak++;
        _score++;
      });
      await CoachDialog.show(context,
          tts: _flutterTts, type: CoachDialogType.success);
      if (!mounted) return;
      _showExplanationDialog();
      return;
    }

    setState(() {
      _correctStreak = 0;
    });

    if (widget.failOnMistake) {
      await CoachDialog.show(context,
          tts: _flutterTts, type: CoachDialogType.failure);
      if (!mounted) return;
      _showWrongAnswerDialog(
          selectedAnswerText: selectedAnswerText,
          onContinue: () {
            _showResult(immediateFail: true);
          });
      return;
    }

    await CoachDialog.show(context,
        tts: _flutterTts, type: CoachDialogType.failure);
    if (!mounted) return;
    _showWrongAnswerDialog(
        selectedAnswerText: selectedAnswerText, onContinue: _nextQuestion);
  }

  void _submitTypedAnswer(TestQuestion question) {
    final typedAnswer = _typedAnswerController.text.trim();
    if (typedAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saisis une reponse avant de valider.')),
      );
      return;
    }

    _answerQuestion(
      _matchesAcceptedAnswer(question, typedAnswer),
      selectedAnswerText: typedAnswer,
    );
  }

  void _submitFillBlankAnswer(TestQuestion question) {
    final typedAnswer = _typedAnswerController.text.trim();
    if (typedAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete la phrase avant de valider.')),
      );
      return;
    }

    _answerQuestion(
      _matchesAcceptedAnswer(question, typedAnswer),
      selectedAnswerText: typedAnswer,
    );
  }

  void _submitReorderAnswer(TestQuestion question) {
    final expected = _expectedReorderItems(question);
    final isCorrect = expected.length == _currentReorderItems.length &&
        expected.asMap().entries.every((entry) {
          return _normalizeAnswer(entry.value) ==
              _normalizeAnswer(_currentReorderItems[entry.key]);
        });

    _answerQuestion(
      isCorrect,
      selectedAnswerText: _currentReorderItems.join(' > '),
    );
  }

  bool _matchesAcceptedAnswer(TestQuestion question, String answer) {
    final normalizedAnswer = _normalizeAnswer(answer);
    final accepted = _acceptedAnswersForQuestion(question)
        .map(_normalizeAnswer)
        .where((value) => value.isNotEmpty)
        .toList();

    return accepted.any((value) {
      return normalizedAnswer == value ||
          (normalizedAnswer.length >= 4 && value.contains(normalizedAnswer));
    });
  }

  List<String> _acceptedAnswersForQuestion(TestQuestion question) {
    if (question.acceptedAnswers.isNotEmpty) return question.acceptedAnswers;
    return [_correctAnswerText(question)];
  }

  String _correctAnswerText(TestQuestion question) {
    return question.answers
        .firstWhere(
          (a) => a.isCorrect,
          orElse: () => question.answers.first,
        )
        .text;
  }

  List<String> _expectedReorderItems(TestQuestion question) {
    if (question.reorderItems.isNotEmpty) return question.reorderItems;

    final correctText = _correctAnswerText(question);
    final parts = correctText
        .split(RegExp(r'\s+(?:puis|et|,|;|>)\s+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    if (parts.length >= 3) return parts;

    return question.answers
        .where((answer) => answer.text.trim().isNotEmpty)
        .take(4)
        .map((answer) => answer.text.trim())
        .toList();
  }

  List<String> _shuffledReorderItems(TestQuestion question) {
    final items = [..._expectedReorderItems(question)];
    if (items.length < 2) return items;
    items.shuffle();
    if (_sameOrder(items, _expectedReorderItems(question))) {
      final first = items.removeAt(0);
      items.add(first);
    }
    return items;
  }

  bool _sameOrder(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  String _fillBlankSentenceForQuestion(TestQuestion question) {
    if (question.fillBlankSentence != null &&
        question.fillBlankSentence!.contains('___')) {
      return question.fillBlankSentence!;
    }

    return '${question.question} ___';
  }

  String _normalizeAnswer(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _showExplanationDialog() {
    final question = _questions[_questionIndex];
    final correctAnswer = question.answers.firstWhere(
      (a) => a.isCorrect,
      orElse: () => question.answers.first,
    );
    final explanation =
        (question.explanation != null && question.explanation!.isNotEmpty)
            ? question.explanation!
            : 'Bonne réponse ! Continuez sur cette lancée.';

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: const Color(0xFF00E676).withValues(alpha: 0.6),
                width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E676).withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color:
                              const Color(0xFF00E676).withValues(alpha: 0.5)),
                    ),
                    child: const Icon(Icons.check_circle,
                        color: Color(0xFF00E676), size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BONNE RÉPONSE',
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'Justification',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Correct answer
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF00E676).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        color: Color(0xFF00E676), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        correctAnswer.text,
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Divider
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.07),
              ),
              const SizedBox(height: 14),
              // Explanation text
              Text(
                explanation,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              // Official link
              if (question.officialLink != null &&
                  question.officialLink!.isNotEmpty) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final uri = Uri.parse(question.officialLink!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.open_in_new,
                          color: Color(0xFF00E5FF), size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Source officielle',
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF00E5FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 22),
              // CTA button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _nextQuestion();
                  },
                  child: const Text(
                    'CONTINUER',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWrongAnswerDialog(
      {String? selectedAnswerText, required VoidCallback onContinue}) {
    final question = _questions[_questionIndex];
    final correctAnswer = question.answers.firstWhere(
      (a) => a.isCorrect,
      orElse: () => question.answers.first,
    );
    final explanation =
        (question.explanation != null && question.explanation!.isNotEmpty)
            ? question.explanation!
            : 'La bonne réponse est indiquée ci-dessus. Révisez ce point.';

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: const Color(0xFFFF5252).withValues(alpha: 0.6),
                width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color:
                              const Color(0xFFFF5252).withValues(alpha: 0.5)),
                    ),
                    child: const Icon(Icons.cancel,
                        color: Color(0xFFFF5252), size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MAUVAISE RÉPONSE',
                        style: TextStyle(
                          color: Color(0xFFFF5252),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'Voici la bonne réponse',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Wrong answer (if known)
              if (selectedAnswerText != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5252).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFFF5252).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.close,
                          color: Color(0xFFFF5252), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          selectedAnswerText,
                          style: const TextStyle(
                            color: Color(0xFFFF5252),
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Color(0xFFFF5252),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              // Correct answer
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF00E676).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Color(0xFF00E676), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        correctAnswer.text,
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.07),
              ),
              const SizedBox(height: 14),
              // Explanation
              Text(
                explanation,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
              // CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onContinue();
                  },
                  child: const Text(
                    'QUESTION SUIVANTE',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextQuestion() {
    _timer?.cancel();
    _typedAnswerController.clear();
    _typedAnswerFocusNode.unfocus();
    _currentReorderItems = const [];

    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex++;
      });
      _startTimer();
      _speakQuestion();
      return;
    }

    _showResult();
  }

  Future<void> _showResult({bool immediateFail = false}) async {
    _timer?.cancel();

    final actualCount = _questions.length;
    final percentage =
        actualCount == 0 ? 0 : (_score / actualCount * 100).toInt();
    final passed = !immediateFail && (_score >= widget.requiredScore);

    await _saveResults(_score, actualCount, passed);

    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          passed ? 'Test reussi !' : 'Test echoue',
          style: TextStyle(
            color: passed ? AppColors.success : AppColors.warning,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_score / $actualCount',
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 24,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              passed
                  ? 'Felicitations ! Vous avez reussi ce test.'
                  : immediateFail
                      ? 'Vous avez fait une erreur, le defi est perdu.'
                      : 'Il faut au moins ${widget.requiredScore}/${_questions.length} pour reussir.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Quitter',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _questionIndex = 0;
                _score = 0;
                _correctStreak = 0;
                _typedAnswerController.clear();
              });
              _startTimer();
              _speakQuestion();
            },
            child: const Text('Recommencer'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveResults(int score, int total, bool passed) async {
    if (total <= 0) return;

    await _progressService.recordTestResult(
      score: score,
      total: total,
      passed: passed,
      permitCode: _selectedPermitCode,
      themeId: widget.themeIdFilter,
    );

    final prefs = await SharedPreferences.getInstance();
    final lastLevelUp = prefs.getInt('last_level_up');
    if (lastLevelUp != null && mounted) {
      await prefs.remove('last_level_up');
      _showLevelUpDialog(lastLevelUp);
    }
  }

  void _showLevelUpDialog(int newLevel) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Level Up',
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.primaryPurple, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Felicitations !',
                      style: TextStyle(
                        color: AppColors.primaryPurple,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Icon(Icons.stars, color: Colors.amber, size: 80),
                    const SizedBox(height: 20),
                    Text(
                      'VOUS ETES PASSE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'NIVEAU $newLevel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        newLevel < 5
                            ? 'Conducteur Debutant'
                            : (newLevel < 15
                                ? 'Conducteur Confirme'
                                : 'Expert de la Route'),
                        style: const TextStyle(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('SUPER !'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMissingImagePlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            'Aucune image associee pour le moment',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionImage(TestQuestion question) {
    Widget buildImage(String path, Widget fallback) {
      if (path.isEmpty) return fallback;
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return Image.network(
          path,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => fallback,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
          },
        );
      }
      return Image.asset(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    return buildImage(
      question.imagePath,
      buildImage(question.fallbackImagePath, _buildMissingImagePlaceholder()),
    );
  }

  Widget _buildAdaptiveBadges(QuestionInteractionStyle style) {
    final styleLabel = switch (style) {
      QuestionInteractionStyle.typedAnswer => 'Reponse saisie',
      QuestionInteractionStyle.reorder => 'A reordonner',
      QuestionInteractionStyle.fillBlank => 'Phrase a completer',
      QuestionInteractionStyle.multipleChoice => 'Choix multiples',
    };
    final styleIcon = switch (style) {
      QuestionInteractionStyle.typedAnswer => Icons.keyboard_alt_rounded,
      QuestionInteractionStyle.reorder => Icons.swap_vert_rounded,
      QuestionInteractionStyle.fillBlank => Icons.short_text_rounded,
      QuestionInteractionStyle.multipleChoice => Icons.checklist_rounded,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildPracticeBadge(
              icon: Icons.trending_up_rounded,
              label: _difficultyLabel,
              color: _difficultyColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildPracticeBadge(
              icon: styleIcon,
              label: styleLabel,
              color: AppColors.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerArea(
    TestQuestion question,
    QuestionInteractionStyle style,
  ) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0.04),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: switch (style) {
        QuestionInteractionStyle.typedAnswer => _buildTypedAnswer(question),
        QuestionInteractionStyle.reorder => _buildReorderAnswer(question),
        QuestionInteractionStyle.fillBlank => _buildFillBlankAnswer(question),
        QuestionInteractionStyle.multipleChoice =>
          _buildMultipleChoiceAnswers(question),
      },
    );
  }

  Widget _buildMultipleChoiceAnswers(TestQuestion question) {
    return Column(
      key: ValueKey('choice-${question.id}'),
      children: question.answers.asMap().entries.map((entry) {
        final idx = entry.key;
        final answer = entry.value;
        final letter = ['A', 'B', 'C', 'D'][idx % 4];

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 180 + (idx * 45)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 14 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cardBackground,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.primaryPurple.withValues(alpha: 0.3),
                  ),
                ),
              ),
              onPressed: () => _answerQuestion(
                answer.isCorrect,
                selectedAnswerText: answer.text,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      letter,
                      style: const TextStyle(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      answer.text,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypedAnswer(TestQuestion question) {
    return Container(
      key: ValueKey('typed-${question.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _difficultyColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: _difficultyColor.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _difficultyColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  color: _difficultyColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Saisis la bonne reponse',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _typedAnswerController,
            focusNode: _typedAnswerFocusNode,
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Ex: ralentir et controler...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.42)),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              prefixIcon: const Icon(
                Icons.keyboard_rounded,
                color: AppColors.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _difficultyColor, width: 1.4),
              ),
            ),
            onSubmitted: (_) => _submitTypedAnswer(question),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _difficultyColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => _submitTypedAnswer(question),
              icon: const Icon(Icons.send_rounded),
              label: const Text(
                'VALIDER MA REPONSE',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFillBlankAnswer(TestQuestion question) {
    final sentence = _fillBlankSentenceForQuestion(question);
    final parts = sentence.split('___');

    return Container(
      key: ValueKey('fill-${question.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.short_text_rounded, color: AppColors.warning),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Complete la phrase',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
              children: [
                TextSpan(text: parts.first),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.45),
                      ),
                    ),
                    child: const Text(
                      '...',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                if (parts.length > 1) TextSpan(text: parts.skip(1).join('')),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _typedAnswerController,
            focusNode: _typedAnswerFocusNode,
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Mot ou expression manquante',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.42)),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              prefixIcon: const Icon(Icons.edit_rounded,
                  color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.warning),
              ),
            ),
            onSubmitted: (_) => _submitFillBlankAnswer(question),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => _submitFillBlankAnswer(question),
              icon: const Icon(Icons.task_alt_rounded),
              label: const Text(
                'VALIDER',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReorderAnswer(TestQuestion question) {
    if (_currentReorderItems.isEmpty) {
      _currentReorderItems = _shuffledReorderItems(question);
    }

    return Container(
      key: ValueKey('reorder-${question.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.swap_vert_rounded, color: AppColors.accentCyan),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Remets les elements dans le bon ordre',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: _currentReorderItems.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _currentReorderItems.removeAt(oldIndex);
                _currentReorderItems.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              final item = _currentReorderItems[index];
              return Container(
                key: ValueKey('reorder-${question.id}-$item'),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.accentCyan.withValues(alpha: 0.25),
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        AppColors.accentCyan.withValues(alpha: 0.16),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: AppColors.accentCyan,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  title: Text(
                    item,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  trailing: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(
                      Icons.drag_handle_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentCyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => _submitReorderAnswer(question),
              icon: const Icon(Icons.done_all_rounded),
              label: const Text(
                'VALIDER L ORDRE',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flutterTts.stop();
    _typedAnswerController.dispose();
    _typedAnswerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingQuestions) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryPurple),
              SizedBox(height: 20),
              Text(
                'Chargement des questions...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Aucune question trouvee',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final question = _questions[_questionIndex];
    final progress = (_questionIndex + 1) / _questions.length;
    final interactionStyle = _interactionStyleForCurrentQuestion(question);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.backgroundDark, Color(0xFF1E1B4B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            _timer?.cancel();
                            Navigator.pop(context);
                          },
                        ),
                        Expanded(
                          child: Text(
                            widget.challengeTitle ??
                                'Question ${_questionIndex + 1}/${_questions.length}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'Score: $_score',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryPurple,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _timeLeft <= 3
                      ? AppColors.warning
                      : AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      '$_timeLeft secondes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_isThemeRevision) ...[
                _buildAdaptiveBadges(interactionStyle),
                const SizedBox(height: 14),
              ],
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  child: SingleChildScrollView(
                    key: ValueKey<int>(question.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Container(
                          height: MediaQuery.sizeOf(context).height * 0.45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(19),
                            child: _buildQuestionImage(question),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          question.question,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildAnswerArea(question, interactionStyle),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
