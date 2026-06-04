// // import 'package:flutter/material.dart';
// // import 'dart:ui';
// // import 'package:code_route_flutter/screens/tests/demo_test_screen.dart';

// // class DemoIntroScreen extends StatelessWidget {
// //   const DemoIntroScreen({Key? key}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFF020617),
// //       body: Stack(
// //         children: [
// //           // Cyber Background
// //           Positioned.fill(
// //             child: Container(
// //               decoration: BoxDecoration(
// //                 gradient: RadialGradient(
// //                   center: const Alignment(0, -0.2),
// //                   radius: 1.5,
// //                   colors: [
// //                     const Color(0xFF00E5FF).withValues(alpha: 0.15),
// //                     const Color(0xFF020617),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),

// //           SafeArea(
// //             child: Padding(
// //               padding:
// //                   const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   const Spacer(),

// //                   // Icon/Logo
// //                   Container(
// //                     width: 120,
// //                     height: 120,
// //                     decoration: BoxDecoration(
// //                       shape: BoxShape.circle,
// //                       color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
// //                       border: Border.all(
// //                           color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
// //                           width: 2),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
// //                           blurRadius: 40,
// //                           spreadRadius: 10,
// //                         ),
// //                       ],
// //                     ),
// //                     child: const Icon(
// //                       Icons.electric_car_rounded,
// //                       size: 60,
// //                       color: Color(0xFF00E5FF),
// //                     ),
// //                   ),

// //                   const SizedBox(height: 40),

// //                   // Text Content
// //                   const Text(
// //                     "ELITE DRIVE",
// //                     style: TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 32,
// //                       fontWeight: FontWeight.w900,
// //                       letterSpacing: 4,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   Text(
// //                     "Le simulateur d'apprentissage de la route de nouvelle génération.",
// //                     textAlign: TextAlign.center,
// //                     style: TextStyle(
// //                       color: Colors.white.withValues(alpha: 0.7),
// //                       fontSize: 16,
// //                       height: 1.5,
// //                     ),
// //                   ),

// //                   const SizedBox(height: 32),

// //                   // Card Instructions
// //                   ClipRRect(
// //                     borderRadius: BorderRadius.circular(20),
// //                     child: BackdropFilter(
// //                       filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
// //                       child: Container(
// //                         padding: const EdgeInsets.all(24),
// //                         decoration: BoxDecoration(
// //                           color: Colors.white.withValues(alpha: 0.05),
// //                           borderRadius: BorderRadius.circular(20),
// //                           border: Border.all(
// //                               color: Colors.white.withValues(alpha: 0.1)),
// //                         ),
// //                         child: Column(
// //                           children: [
// //                             const Icon(Icons.rocket_launch_rounded,
// //                                 color: Color(0xFF00E676), size: 32),
// //                             const SizedBox(height: 16),
// //                             const Text(
// //                               "TEST D'ÉVALUATION",
// //                               style: TextStyle(
// //                                 color: Color(0xFF00E676),
// //                                 fontSize: 14,
// //                                 fontWeight: FontWeight.bold,
// //                                 letterSpacing: 1.5,
// //                               ),
// //                             ),
// //                             const SizedBox(height: 8),
// //                             Text(
// //                               "Avant de commencer, faisons une petite démo de 4 questions pour évaluer votre niveau de base.",
// //                               textAlign: TextAlign.center,
// //                               style: TextStyle(
// //                                   color: Colors.white.withValues(alpha: 0.6),
// //                                   fontSize: 13,
// //                                   height: 1.5),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),

// //                   const Spacer(),

// //                   // Button
// //                   SizedBox(
// //                     width: double.infinity,
// //                     height: 56,
// //                     child: ElevatedButton(
// //                       onPressed: () {
// //                         Navigator.pushReplacement(
// //                           context,
// //                           MaterialPageRoute(
// //                               builder: (_) => const DemoTestScreen()),
// //                         );
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: const Color(0xFF00E5FF),
// //                         foregroundColor: Colors.black,
// //                         shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(16)),
// //                         elevation: 0,
// //                       ),
// //                       child: const Text(
// //                         "DÉMARRER LA DÉMO",
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.w900,
// //                           letterSpacing: 1.5,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:code_route_flutter/screens/tests/demo_test_screen.dart';

// class DemoIntroScreen extends StatelessWidget {
//   const DemoIntroScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF020617),
//       body: Stack(
//         children: [
//           // Cyber Background
//           Positioned.fill(
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: RadialGradient(
//                   center: const Alignment(0, -0.2),
//                   radius: 1.5,
//                   colors: [
//                     const Color(0xFF00E5FF).withValues(alpha: 0.15),
//                     const Color(0xFF020617),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           SafeArea(
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 24.0, vertical: 40.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const SizedBox(height: 40),

//                     // Icon/Logo
//                     Container(
//                       width: 120,
//                       height: 120,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
//                         border: Border.all(
//                             color:
//                                 const Color(0xFF00E5FF).withValues(alpha: 0.3),
//                             width: 2),
//                         boxShadow: [
//                           BoxShadow(
//                             color:
//                                 const Color(0xFF00E5FF).withValues(alpha: 0.2),
//                             blurRadius: 40,
//                             spreadRadius: 10,
//                           ),
//                         ],
//                       ),
//                       child: const Icon(
//                         Icons.electric_car_rounded,
//                         size: 60,
//                         color: Color(0xFF00E5FF),
//                       ),
//                     ),

//                     const SizedBox(height: 40),

//                     // Text Content
//                     const Text(
//                       "ELITE DRIVE",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 32,
//                         fontWeight: FontWeight.w900,
//                         letterSpacing: 4,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       "Le simulateur d'apprentissage de la route de nouvelle génération.",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.white.withValues(alpha: 0.7),
//                         fontSize: 16,
//                         height: 1.5,
//                       ),
//                     ),

//                     const SizedBox(height: 32),

//                     // Card Instructions
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(20),
//                       child: BackdropFilter(
//                         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                         child: Container(
//                           padding: const EdgeInsets.all(24),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withValues(alpha: 0.05),
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(
//                                 color: Colors.white.withValues(alpha: 0.1)),
//                           ),
//                           child: Column(
//                             children: [
//                               const Icon(Icons.rocket_launch_rounded,
//                                   color: Color(0xFF00E676), size: 32),
//                               const SizedBox(height: 16),
//                               const Text(
//                                 "TEST D'ÉVALUATION",
//                                 style: TextStyle(
//                                   color: Color(0xFF00E676),
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 1.5,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 "Avant de commencer, faisons une petite démo de 4 questions pour évaluer votre niveau de base.",
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                     color: Colors.white.withValues(alpha: 0.6),
//                                     fontSize: 13,
//                                     height: 1.5),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 60),

//                     // Button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) => const DemoTestScreen()),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF00E5FF),
//                           foregroundColor: Colors.black,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16)),
//                           elevation: 0,
//                         ),
//                         child: const Text(
//                           "DÉMARRER LA DÉMO",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w900,
//                             letterSpacing: 1.5,
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:code_route_flutter/screens/tests/demo_test_screen.dart';

class DemoIntroScreen extends StatefulWidget {
  const DemoIntroScreen({Key? key}) : super(key: key);

  @override
  State<DemoIntroScreen> createState() => _DemoIntroScreenState();
}

class _DemoIntroScreenState extends State<DemoIntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconFade;
  late Animation<Offset> _iconSlide;
  late Animation<double> _titleFade;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;
  late Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _iconFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _iconSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 0.6, curve: Curves.easeOut)),
    );

    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.5, 0.8, curve: Curves.easeOut)),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut)));

    _buttonFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.75, 1.0, curve: Curves.easeOut)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF22C55E).withValues(alpha: 0.06),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: isTablet ? 480 : double.infinity),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 40 : 28,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),

                      // ── Icône animée ─────────────────────────
                      FadeTransition(
                        opacity: _iconFade,
                        child: SlideTransition(
                          position: _iconSlide,
                          child: Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1E40AF)
                                    .withValues(alpha: 0.09),
                                border: Border.all(
                                  color: const Color(0xFF1E40AF)
                                      .withValues(alpha: 0.20),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1E40AF)
                                        .withValues(alpha: 0.12),
                                    blurRadius: 28,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.electric_car_rounded,
                                size: 48,
                                color: Color(0xFF1E40AF),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Titre ────────────────────────────────
                      FadeTransition(
                        opacity: _titleFade,
                        child: Column(
                          children: [
                            const Text(
                              'ELITE DRIVE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                letterSpacing: 5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Le simulateur d\'apprentissage\nde la route nouvelle génération.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: const Color(0xFF64748B),
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Carte évaluation ─────────────────────
                      FadeTransition(
                        opacity: _cardFade,
                        child: SlideTransition(
                          position: _cardSlide,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.07),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E)
                                        .withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF22C55E)
                                          .withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.rocket_launch_rounded,
                                          color: Color(0xFF22C55E), size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        'TEST D\'ÉVALUATION GRATUIT',
                                        style: TextStyle(
                                          color: Color(0xFF22C55E),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                const Text(
                                  'Testez votre niveau en 4 questions',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    height: 1.3,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  'Avant de commencer, faites une démo rapide pour évaluer votre niveau de base. Aucune inscription requise.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: const Color(0xFF64748B),
                                    height: 1.6,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // 3 points clés
                                Row(
                                  children: [
                                    _buildFeature(
                                      Icons.timer_outlined,
                                      '2 min',
                                      'Rapide',
                                      const Color(0xFF3B82F6),
                                    ),
                                    _buildFeature(
                                      Icons.quiz_outlined,
                                      '4 QCM',
                                      'Questions',
                                      const Color(0xFF8B5CF6),
                                    ),
                                    _buildFeature(
                                      Icons.emoji_events_outlined,
                                      'Score',
                                      'Immédiat',
                                      const Color(0xFFF59E0B),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Bouton ───────────────────────────────
                      FadeTransition(
                        opacity: _buttonFade,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (c, a, b) =>
                                          const DemoTestScreen(),
                                      transitionsBuilder: (c, a, b, child) =>
                                          FadeTransition(
                                              opacity: a, child: child),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E40AF),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Démarrer la démo',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(Icons.arrow_forward_rounded,
                                        size: 20),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Lien discret
                            Center(
                              child: Text(
                                'Sans inscription · Résultat immédiat',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildFeature(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}