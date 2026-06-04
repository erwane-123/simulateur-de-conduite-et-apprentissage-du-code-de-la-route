import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:code_route_flutter/data/test_questions.dart';
import 'package:code_route_flutter/models/test_question.dart';
import 'package:code_route_flutter/screens/arena/arena_result_screen.dart';

class ArenaGameScreen extends StatefulWidget {
  const ArenaGameScreen({Key? key}) : super(key: key);

  @override
  State<ArenaGameScreen> createState() => _ArenaGameScreenState();
}

class _ArenaGameScreenState extends State<ArenaGameScreen> {
  late List<TestQuestion> _arenaQuestions;
  int _currentIdx = 0;
  int _userScore = 0;
  int _opponentScore = 0;
  double _userProgress = 0.0;
  double _opponentProgress = 0.0;
  
  int _timeLeft = 15;
  Timer? _timer;
  Timer? _opponentTimer;
  
  bool _answered = false;
  int? _selectedIdx;

  @override
  void initState() {
    super.initState();
    // Pick 10 random questions
    final all = getTestQuestions();
    all.shuffle();
    _arenaQuestions = all.take(10).toList();
    
    _startQuestion();
  }

  void _startQuestion() {
    setState(() {
      _timeLeft = 15;
      _answered = false;
      _selectedIdx = null;
    });
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _nextQuestion();
      }
    });

    // Simulated Opponent Logic
    _simulateOpponent();
  }

  void _simulateOpponent() {
    _opponentTimer?.cancel();
    // Opponent answers between 3 and 10 seconds
    final delay = 3 + math.Random().nextInt(7);
    _opponentTimer = Timer(Duration(seconds: delay), () {
      if (mounted && !_answered && _currentIdx < _arenaQuestions.length) {
        // 75% chance of being correct
        bool correct = math.Random().nextDouble() < 0.75;
        if (correct) {
          setState(() {
            _opponentScore += 10 + _timeLeft; // Speed bonus
            _opponentProgress = (_currentIdx + 1) / _arenaQuestions.length;
          });
        }
      }
    });
  }

  void _handleAnswer(int idx) {
    if (_answered) return;
    
    _timer?.cancel();
    setState(() {
      _answered = true;
      _selectedIdx = idx;
      bool correct = _arenaQuestions[_currentIdx].answers[idx].isCorrect;
      if (correct) {
        _userScore += 10 + _timeLeft; // Speed bonus
      }
      _userProgress = (_currentIdx + 1) / _arenaQuestions.length;
    });

    Future.delayed(const Duration(seconds: 1), _nextQuestion);
  }

  void _nextQuestion() {
    if (_currentIdx < _arenaQuestions.length - 1) {
      setState(() {
        _currentIdx++;
      });
      _startQuestion();
    } else {
      _finishGame();
    }
  }

  void _finishGame() {
    _timer?.cancel();
    _opponentTimer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ArenaResultScreen(
          userScore: _userScore,
          opponentScore: _opponentScore,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _opponentTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = _arenaQuestions[_currentIdx];
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Column(
        children: [
          _buildScoreBoard(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildQuestionCard(question),
                  const SizedBox(height: 24),
                  ...List.generate(question.answers.length, (index) {
                    return _buildAnswerOption(index, question.answers[index]);
                  }),
                ],
              ),
            ),
          ),
          _buildFooterProgress(),
        ],
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ScoreNode(name: 'VOUS', score: _userScore, color: const Color(0xFF00E5FF)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _timeLeft < 5 ? Colors.red : const Color(0xFF7C3AED)),
                ),
                child: Text(
                  '00:${_timeLeft.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: _timeLeft < 5 ? Colors.red : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
              _ScoreNode(name: 'DARK_ACE', score: _opponentScore, color: const Color(0xFFF43F5E)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _ProgressBar(value: _userProgress, color: const Color(0xFF00E5FF))),
              const SizedBox(width: 20),
              Expanded(child: _ProgressBar(value: _opponentProgress, color: const Color(0xFFF43F5E))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(TestQuestion q) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(
            'QUESTION ${_currentIdx + 1}/10',
            style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2),
          ),
          const SizedBox(height: 16),
          Text(
            q.question,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(int idx, Answer a) {
    bool isSelected = _selectedIdx == idx;
    Color borderColor = Colors.white.withOpacity(0.1);
    Color bgColor = const Color(0xFF1E293B);
    
    if (_answered) {
      if (a.isCorrect) {
        borderColor = const Color(0xFF10B981);
        bgColor = const Color(0xFF10B981).withOpacity(0.1);
      } else if (isSelected) {
        borderColor = const Color(0xFFF43F5E);
        bgColor = const Color(0xFFF43F5E).withOpacity(0.1);
      }
    } else if (isSelected) {
      borderColor = const Color(0xFF7C3AED);
    }

    return GestureDetector(
      onTap: () => _handleAnswer(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + idx),
                  style: TextStyle(color: borderColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                a.text,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.black.withOpacity(0.2),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flash_on_rounded, color: Color(0xFFF59E0B), size: 16),
          SizedBox(width: 8),
          Text(
            'RÉPONDEZ VITE POUR UN BONUS DE POINTS !',
            style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _ScoreNode extends StatelessWidget {
  final String name;
  final int score;
  final Color color;

  const _ScoreNode({required this.name, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        Text(
          score.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;

  const _ProgressBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: Colors.white.withOpacity(0.05),
        color: color,
        minHeight: 8,
      ),
    );
  }
}
