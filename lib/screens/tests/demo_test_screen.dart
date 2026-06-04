import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:code_route_flutter/models/test_question.dart';
import 'package:code_route_flutter/data/permit_question_bank.dart';
import 'package:code_route_flutter/widgets/coach_dialog.dart';
import 'package:code_route_flutter/screens/auth/login_screen.dart';

class DemoTestScreen extends StatefulWidget {
  const DemoTestScreen({Key? key}) : super(key: key);

  @override
  State<DemoTestScreen> createState() => _DemoTestScreenState();
}

class _DemoTestScreenState extends State<DemoTestScreen> {
  late FlutterTts _flutterTts;
  List<TestQuestion> _questions = [];
  int _questionIndex = 0;
  int _score = 0;
  int _timeLeft = 15;
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadDemoQuestions();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('fr-FR');
    await _flutterTts.setSpeechRate(0.5);
  }

  void _loadDemoQuestions() async {
    // Get 4 random questions from the local bank for the demo
    final allQuestions = PermitQuestionBank.getQuestionsForPermit('B');
    allQuestions.shuffle();
    _questions = allQuestions.take(4).toList();

    for (var q in _questions) {
      q.answers.shuffle();
    }

    setState(() {
      _isLoading = false;
    });

    await CoachDialog.show(
      context,
      tts: _flutterTts,
      type: CoachDialogType.intro,
    );

    if (mounted) {
      _startTimer();
      _speakQuestion();
    }
  }

  void _startTimer() {
    _timeLeft = 15;
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

  Future<void> _answerQuestion(bool correct) async {
    _timer?.cancel();
    if (correct) {
      _score++;
      await CoachDialog.show(context,
          tts: _flutterTts, type: CoachDialogType.success);
    } else {
      await CoachDialog.show(context,
          tts: _flutterTts, type: CoachDialogType.failure);
    }

    if (mounted) {
      _nextQuestion();
    }
  }

  void _nextQuestion() {
    _timer?.cancel();
    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex++;
      });
      _startTimer();
      _speakQuestion();
    } else {
      _showDemoResult();
    }
  }

  Future<void> _showDemoResult() async {
    _timer?.cancel();
    await _flutterTts.stop();

    final percentage = (_score / _questions.length * 100).toInt();
    final passed = _score >= 3;

    // Annoncer le résultat
    String resultSpeech = passed
        ? "Excellent ! Tu as un bon niveau de base. Inscris-toi pour continuer."
        : "Pas mal ! Il y a encore des choses à apprendre. Inscris-toi pour commencer ton entraînement.";

    await _flutterTts.speak(resultSpeech);

    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
                color:
                    passed ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                width: 2)),
        title: Text(
          passed ? 'DÉMO RÉUSSIE !' : 'FIN DE LA DÉMO',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: passed ? const Color(0xFF00E676) : Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_score / ${_questions.length}',
              style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage% de bonnes réponses',
              style:
                  TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 24),
            Text(
              passed
                  ? "Vous avez les bases ! Créez votre profil pour sauvegarder vos futurs progrès."
                  : "C'est un bon début ! Connectez-vous pour commencer le programme d'entraînement Elite Drive.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, height: 1.5),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                _flutterTts.stop();
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginScreen(isFromDemo: true)),
                );
              },
              child: const Text('SE CONNECTER / S\'INSCRIRE',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingImagePlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
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
          errorBuilder: (context, error, stackTrace) => fallback,
        );
      }
      return Image.asset(path,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallback);
    }

    return buildImage(
        question.imagePath,
        buildImage(
            question.fallbackImagePath, _buildMissingImagePlaceholder()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          backgroundColor: Color(0xFF0F172A),
          body: Center(child: CircularProgressIndicator()));
    }

    final question = _questions[_questionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'DÉMO : ${_questionIndex + 1} / ${_questions.length}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _timeLeft <= 5
                          ? const Color(0xFFFF5252).withOpacity(0.2)
                          : const Color(0xFF00E5FF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _timeLeft <= 5
                              ? const Color(0xFFFF5252)
                              : const Color(0xFF00E5FF)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer_outlined,
                            size: 16,
                            color: _timeLeft <= 5
                                ? const Color(0xFFFF5252)
                                : const Color(0xFF00E5FF)),
                        const SizedBox(width: 8),
                        Text(
                          '$_timeLeft s',
                          style: TextStyle(
                            color: _timeLeft <= 5
                                ? const Color(0xFFFF5252)
                                : const Color(0xFF00E5FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Image
            Expanded(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _buildQuestionImage(question),
                ),
              ),
            ),

            // Question text
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                question.question,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),

            // Answers
            Expanded(
              flex: 5,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: question.answers.length,
                itemBuilder: (context, index) {
                  final answer = question.answers[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _answerQuestion(answer.isCorrect),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index), // A, B, C...
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                answer.text,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
