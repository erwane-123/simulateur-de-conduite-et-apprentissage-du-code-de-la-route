import 'package:flutter/material.dart';

class ArenaResultScreen extends StatelessWidget {
  final int userScore;
  final int opponentScore;

  const ArenaResultScreen({
    Key? key,
    required this.userScore,
    required this.opponentScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isWin = userScore >= opponentScore;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isWin ? const Color(0xFF10B981) : const Color(0xFFF43F5E)).withOpacity(0.15),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildResultIcon(isWin),
                  const SizedBox(height: 32),
                  Text(
                    isWin ? 'VICTOIRE !' : 'DÉFAITE...',
                    style: TextStyle(
                      color: isWin ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isWin ? 'Vous avez dominé l\'arène.' : 'L\'adversaire était plus rapide.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
                  ),
                  const SizedBox(height: 60),
                  _buildScoreComparison(),
                  const Spacer(),
                  _buildActions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultIcon(bool isWin) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: (isWin ? const Color(0xFF10B981) : const Color(0xFFF43F5E)).withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: (isWin ? const Color(0xFF10B981) : const Color(0xFFF43F5E)).withOpacity(0.5),
          width: 4,
        ),
      ),
      child: Icon(
        isWin ? Icons.emoji_events_rounded : Icons.sentiment_very_dissatisfied_rounded,
        color: isWin ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
        size: 64,
      ),
    );
  }

  Widget _buildScoreComparison() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ResultScoreNode(label: 'VOUS', score: userScore, isUser: true),
          Container(height: 40, width: 2, color: Colors.white.withOpacity(0.1)),
          _ResultScoreNode(label: 'OPPOSANT', score: opponentScore, isUser: false),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('RETOUR À L\'ARÈNE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: Text(
            'MENU PRINCIPAL',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _ResultScoreNode extends StatelessWidget {
  final String label;
  final int score;
  final bool isUser;

  const _ResultScoreNode({required this.label, required this.score, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(
          score.toString(),
          style: TextStyle(
            color: isUser ? const Color(0xFF00E5FF) : const Color(0xFFF43F5E),
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
