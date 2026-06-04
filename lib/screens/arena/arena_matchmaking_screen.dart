import 'package:flutter/material.dart';
import 'dart:async';
import 'package:code_route_flutter/screens/arena/arena_game_screen.dart';

class ArenaMatchmakingScreen extends StatefulWidget {
  const ArenaMatchmakingScreen({Key? key}) : super(key: key);

  @override
  State<ArenaMatchmakingScreen> createState() => _ArenaMatchmakingScreenState();
}

class _ArenaMatchmakingScreenState extends State<ArenaMatchmakingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _statusText = 'RECHERCHE DE PILOTES...';
  bool _opponentFound = false;
  
  final List<String> _searchingTexts = [
    'CONNEXION AUX SATELLITES...',
    'ANALYSE DES RÉSEAUX...',
    'RECHERCHE DE PILOTES...',
    'SYNC. AVEC LE SERVEUR...',
    'PILOTE TROUVÉ !',
  ];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startMatchmaking();
  }

  void _startMatchmaking() {
    int count = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      count++;
      if (count < _searchingTexts.length) {
        setState(() {
          _statusText = _searchingTexts[count];
        });
      } else {
        timer.cancel();
        _foundOpponent();
      }
    });
  }

  void _foundOpponent() {
    setState(() {
      _opponentFound = true;
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ArenaGameScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: Stack(
        children: [
          // Animated Background Radar
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(3, (index) {
                    double progress = (_controller.value + (index / 3)) % 1.0;
                    return Container(
                      width: 100 + (progress * 300),
                      height: 100 + (progress * 300),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF7C3AED).withOpacity(1.0 - progress),
                          width: 2,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                Text(
                  _statusText,
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const Spacer(),
                _buildMatchup(),
                const Spacer(),
                _buildLoadingFooter(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchup() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ProfileNode(name: 'VOUS', rank: 'PILOTE RANG 5', isUser: true),
          const Text(
            'VS',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
          ),
          _opponentFound 
            ? _ProfileNode(name: 'DARK_ACE', rank: 'PILOTE RANG 7', isUser: false)
            : const _SearchingNode(),
        ],
      ),
    );
  }

  Widget _buildLoadingFooter() {
    return Container(
      width: 200,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                left: _controller.value * 160,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: const [BoxShadow(color: Color(0xFF7C3AED), blurRadius: 10)],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileNode extends StatelessWidget {
  final String name;
  final String rank;
  final bool isUser;

  const _ProfileNode({required this.name, required this.rank, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: isUser ? const Color(0xFF00E5FF) : const Color(0xFFF43F5E), width: 3),
            boxShadow: [
              BoxShadow(
                color: (isUser ? const Color(0xFF00E5FF) : const Color(0xFFF43F5E)).withOpacity(0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: const Color(0xFF1E293B),
            child: Icon(isUser ? Icons.person : Icons.bolt, color: Colors.white, size: 40),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
        ),
        Text(
          rank,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _SearchingNode extends StatelessWidget {
  const _SearchingNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
          ),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '???',
          style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const Text(
          'EN ATTENTE...',
          style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

extension on BoxDecoration {
  // Dummy extension to simulate dashArray if needed, or just use normal border
}
