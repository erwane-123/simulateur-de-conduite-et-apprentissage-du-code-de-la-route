import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:confetti/confetti.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:code_route_flutter/screens/home/main_navigation.dart';

// class WelcomeCelebrationScreen extends StatefulWidget {
//   const WelcomeCelebrationScreen({Key? key}) : super(key: key);

//   @override
//   State<WelcomeCelebrationScreen> createState() =>
//       _WelcomeCelebrationScreenState();
// }

// class _WelcomeCelebrationScreenState extends State<WelcomeCelebrationScreen> {
//   late ConfettiController _confettiController;
//   final FlutterTts _tts = FlutterTts();

//   @override
//   void initState() {
//     super.initState();
//     _confettiController =
//         ConfettiController(duration: const Duration(seconds: 3));

//     // Jouer l'effet et la voix
//     Future.delayed(const Duration(milliseconds: 500), () async {
//       _confettiController.play();
//       _playWelcomeVoice();

//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('has_seen_onboarding', true);
//     });

//     // Naviguer vers le menu principal après 5 secondes
//     Future.delayed(const Duration(seconds: 5), () {
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const MainNavigation()),
//         );
//       }
//     });
//   }

//   Future<void> _playWelcomeVoice() async {
//     await _tts.setLanguage('fr-FR');
//     await _tts.setSpeechRate(kIsWeb ? 1.0 : 0.5);
//     await _tts.speak(
//         "Bienvenue à bord mon ami ! Préparez-vous à l'aventure Elite Drive.");
//   }

//   @override
//   void dispose() {
//     _confettiController.dispose();
//     _tts.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF020617),
//       body: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Cyber Background Glow
//           Positioned(
//             top: MediaQuery.of(context).size.height * 0.3,
//             child: Container(
//               width: 300,
//               height: 300,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                       color: const Color(0xFF00E676).withValues(alpha: 0.3),
//                       blurRadius: 100,
//                       spreadRadius: 50),
//                 ],
//               ),
//             ),
//           ),

//           // Confetti System
//           Align(
//             alignment: Alignment.topCenter,
//             child: ConfettiWidget(
//               confettiController: _confettiController,
//               blastDirection: 3.14 / 2, // vers le bas
//               maxBlastForce: 5,
//               minBlastForce: 2,
//               emissionFrequency: 0.05,
//               numberOfParticles: 50,
//               gravity: 0.1,
//               colors: const [
//                 Color(0xFF00E5FF),
//                 Color(0xFF00E676),
//                 Color(0xFFFF5252),
//                 Colors.amber
//               ],
//             ),
//           ),

//           // Contenu Central
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Avatar du Coach (Simulé)
//               Container(
//                 width: 150,
//                 height: 150,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.white.withValues(alpha: 0.1),
//                   border: Border.all(color: const Color(0xFF00E676), width: 3),
//                   image: const DecorationImage(
//                     image: AssetImage(
//                         'assets/images/coach.png'), // Si l'image existe, sinon l'icône prend le relai
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 child: const Icon(Icons.support_agent_rounded,
//                     size: 80, color: Color(0xFF00E676)),
//               ),
//               const SizedBox(height: 32),

//               const Text(
//                 "BIENVENUE À BORD",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 28,
//                   fontWeight: FontWeight.w900,
//                   letterSpacing: 2,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 "Votre entraînement commence maintenant.",
//                 style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:code_route_flutter/screens/home/main_navigation.dart';

class WelcomeCelebrationScreen extends StatefulWidget {
  const WelcomeCelebrationScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeCelebrationScreen> createState() =>
      _WelcomeCelebrationScreenState();
}

class _WelcomeCelebrationScreenState extends State<WelcomeCelebrationScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _mainController;
  late AnimationController _pulseController;
  final FlutterTts _tts = FlutterTts();

  late Animation<double> _iconScale;
  late Animation<double> _iconFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _buttonFade;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4));

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _iconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 0.85, curve: Curves.easeOut),
      ),
    );
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.80, 1.0, curve: Curves.easeOut),
      ),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _confettiController.play();
    _mainController.forward();
    _playWelcomeVoice();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }

  Future<void> _playWelcomeVoice() async {
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(kIsWeb ? 1.0 : 0.5);
    await _tts.speak(
        "Bienvenue à bord mon ami ! Préparez-vous à l'aventure Elite Drive.");
  }

  void _goToMain() {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (c, a, b) => const MainNavigation(),
      transitionsBuilder: (c, a, b, child) =>
          FadeTransition(opacity: a, child: child),
      transitionDuration: const Duration(milliseconds: 500),
    ));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _mainController.dispose();
    _pulseController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Cercles décoratifs
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF22C55E).withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withValues(alpha: 0.06),
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 20,
              minBlastForce: 8,
              emissionFrequency: 0.04,
              numberOfParticles: 20,
              gravity: 0.15,
              colors: const [
                Color(0xFF3B82F6),
                Color(0xFF22C55E),
                Color(0xFFF59E0B),
                Color(0xFFEF4444),
                Color(0xFF8B5CF6),
              ],
            ),
          ),

          // Contenu principal
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: isTablet ? 480 : double.infinity),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // ── Icône animée ─────────────────────────
                      AnimatedBuilder(
                        animation: Listenable.merge(
                            [_mainController, _pulseController]),
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _iconFade,
                            child: ScaleTransition(
                              scale: _iconScale,
                              child: Transform.scale(
                                scale: _pulse.value,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF22C55E)
                                        .withValues(alpha: 0.10),
                                    border: Border.all(
                                      color: const Color(0xFF22C55E)
                                          .withValues(alpha: 0.30),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF22C55E)
                                            .withValues(alpha: 0.15),
                                        blurRadius: 30,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.celebration_rounded,
                                    size: 56,
                                    color: Color(0xFF22C55E),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 36),

                      // ── Titre ────────────────────────────────
                      FadeTransition(
                        opacity: _textFade,
                        child: SlideTransition(
                          position: _textSlide,
                          child: const Text(
                            'Bienvenue à bord !',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Sous-titre ───────────────────────────
                      FadeTransition(
                        opacity: _subtitleFade,
                        child: const Text(
                          'Votre compte est créé avec succès.\nVotre entraînement commence maintenant.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF64748B),
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Carte récapitulatif ──────────────────
                      FadeTransition(
                        opacity: _subtitleFade,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildFeatureTile(
                                icon: Icons.quiz_rounded,
                                color: const Color(0xFF3B82F6),
                                title: 'Quiz & simulations',
                                subtitle: 'Entraînez-vous sur des vraies questions',
                              ),
                              const SizedBox(height: 14),
                              _buildFeatureTile(
                                icon: Icons.groups_2_rounded,
                                color: const Color(0xFF8B5CF6),
                                title: 'Mode Auto-École',
                                subtitle: 'Liez-vous à votre moniteur',
                              ),
                              const SizedBox(height: 14),
                              _buildFeatureTile(
                                icon: Icons.emoji_events_rounded,
                                color: const Color(0xFFF59E0B),
                                title: 'Progression & XP',
                                subtitle: 'Montez en niveau à chaque test',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Bouton commencer ─────────────────────
                      FadeTransition(
                        opacity: _buttonFade,
                        child: SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _goToMain,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E40AF),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Commencer l\'aventure',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.check_circle_rounded,
            color: color.withValues(alpha: 0.60), size: 18),
      ],
    );
  }
}