// import 'package:flutter/material.dart';
// import 'package:code_route_flutter/main.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _logoController;
//   late AnimationController _carController;
//   late AnimationController _glowController;
//   late AnimationController _textController;

//   late Animation<double> _logoScale;
//   late Animation<double> _logoFade;
//   late Animation<double> _carPosition;
//   late Animation<double> _glowPulse;
//   late Animation<double> _textFade;
//   late Animation<double> _textSlide;

//   @override
//   void initState() {
//     super.initState();

//     // Logo animation: pop in
//     _logoController = AnimationController(
//       duration: const Duration(milliseconds: 700),
//       vsync: this,
//     );
//     _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
//     );
//     _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.5)),
//     );

//     // Car zoom from left to right
//     _carController = AnimationController(
//       duration: const Duration(milliseconds: 900),
//       vsync: this,
//     );
//     _carPosition = Tween<double>(begin: -1.5, end: 1.5).animate(
//       CurvedAnimation(parent: _carController, curve: Curves.easeInCubic),
//     );

//     // Neon glow pulse
//     _glowController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     )..repeat(reverse: true);
//     _glowPulse = Tween<double>(begin: 0.6, end: 1.0).animate(
//       CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
//     );

//     // Text slide up
//     _textController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(_textController);
//     _textSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
//       CurvedAnimation(parent: _textController, curve: Curves.easeOut),
//     );

//     // Sequence
//     _runSequence();
//   }

//   Future<void> _runSequence() async {
//     await Future.delayed(const Duration(milliseconds: 100));
//     _logoController.forward();
//     await Future.delayed(const Duration(milliseconds: 400));
//     _carController.forward();
//     await Future.delayed(const Duration(milliseconds: 300));
//     _textController.forward();
//     await Future.delayed(const Duration(milliseconds: 900));

//     if (mounted) {
//       Navigator.of(context).pushReplacement(
//         PageRouteBuilder(
//           pageBuilder: (context, animation, secondaryAnimation) =>
//               const AuthWrapper(),
//           transitionsBuilder: (context, animation, secondaryAnimation, child) {
//             return FadeTransition(opacity: animation, child: child);
//           },
//           transitionDuration: const Duration(milliseconds: 600),
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _logoController.dispose();
//     _carController.dispose();
//     _glowController.dispose();
//     _textController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: const Color(0xFF050E1A),
//       body: Stack(
//         children: [
//           // Background grid lines (cyberpunk)
//           CustomPaint(
//             size: size,
//             painter: _GridPainter(),
//           ),

//           // Neon horizontal line (car trail)
//           Positioned.fill(
//             child: AnimatedBuilder(
//               animation: _carController,
//               builder: (context, child) {
//                 return CustomPaint(
//                   painter: _CarTrailPainter(_carPosition.value, size),
//                 );
//               },
//             ),
//           ),

//           // Car emoji zooming across
//           AnimatedBuilder(
//             animation: _carController,
//             builder: (context, child) {
//               return Positioned(
//                 left: size.width * (_carPosition.value + 1) / 2 - 30,
//                 top: size.height * 0.5 - 25,
//                 child: Opacity(
//                   opacity: _carPosition.value > -1.4 && _carPosition.value < 1.4
//                       ? 1.0
//                       : 0.0,
//                   child: Transform(
//                     alignment: Alignment.center,
//                     transform: Matrix4.identity()
//                       ..scaleByDouble(
//                         1.0 + (_carPosition.value.abs() * 0.1),
//                         1.0 + (_carPosition.value.abs() * 0.1),
//                         1.0,
//                         1.0,
//                       ),
//                     child: const Text('🏎️', style: TextStyle(fontSize: 48)),
//                   ),
//                 ),
//               );
//             },
//           ),

//           // Center content: logo + text
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 60),

//                 // Logo avec glow néon
//                 AnimatedBuilder(
//                   animation:
//                       Listenable.merge([_logoController, _glowController]),
//                   builder: (context, child) {
//                     return FadeTransition(
//                       opacity: _logoFade,
//                       child: ScaleTransition(
//                         scale: _logoScale,
//                         child: Container(
//                           width: 140,
//                           height: 140,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color(0xFF00FFCC).withValues(
//                                     alpha: 0.4 * _glowPulse.value),
//                                 blurRadius: 30 * _glowPulse.value,
//                                 spreadRadius: 8 * _glowPulse.value,
//                               ),
//                             ],
//                           ),
//                           child: ClipOval(
//                             child: Image.asset(
//                               'assets/images/logo.png',
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Container(
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: const Color(0xFF0A1628),
//                                     border: Border.all(
//                                       color: const Color(0xFF00FFCC),
//                                       width: 2,
//                                     ),
//                                   ),
//                                   child: const Center(
//                                     child: Text('🏎️',
//                                         style: TextStyle(fontSize: 60)),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 28),

//                 // Texte Elite Drive
//                 AnimatedBuilder(
//                   animation: _textController,
//                   builder: (context, child) {
//                     return FadeTransition(
//                       opacity: _textFade,
//                       child: Transform.translate(
//                         offset: Offset(0, _textSlide.value),
//                         child: Column(
//                           children: [
//                             // ELITE DRIVE avec effet néon
//                             ShaderMask(
//                               shaderCallback: (bounds) => const LinearGradient(
//                                 colors: [
//                                   Color(0xFF00FFCC),
//                                   Color(0xFF00D4FF),
//                                 ],
//                               ).createShader(bounds),
//                               child: const Text(
//                                 'ELITE DRIVE',
//                                 style: TextStyle(
//                                   fontSize: 32,
//                                   fontWeight: FontWeight.w900,
//                                   color: Colors.white,
//                                   letterSpacing: 6,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Le simulateur de conduite nouvelle génération',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.white.withValues(alpha: 0.5),
//                                 letterSpacing: 1,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),

//           // Ligne néon bas
//           Positioned(
//             bottom: 40,
//             left: 0,
//             right: 0,
//             child: AnimatedBuilder(
//               animation: _glowController,
//               builder: (context, child) {
//                 return Center(
//                   child: Container(
//                     width: 60,
//                     height: 3,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(2),
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.transparent,
//                           Color(0xFF00FFCC)
//                               .withValues(alpha: _glowPulse.value),
//                           Colors.transparent,
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Grille de fond style cyberpunk
// class _GridPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFF00FFCC).withValues(alpha: 0.04)
//       ..strokeWidth = 1;

//     const step = 40.0;
//     for (double x = 0; x < size.width; x += step) {
//       canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
//     }
//     for (double y = 0; y < size.height; y += step) {
//       canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// // Traînée lumineuse de la voiture
// class _CarTrailPainter extends CustomPainter {
//   final double carPos;
//   final Size screenSize;

//   _CarTrailPainter(this.carPos, this.screenSize);

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (carPos < -1.3 || carPos > 1.3) return;

//     final centerX = size.width * (carPos + 1) / 2;
//     final centerY = size.height * 0.5;

//     final paint = Paint()
//       ..shader = LinearGradient(
//         colors: [
//           Colors.transparent,
//           const Color(0xFF00FFCC).withValues(alpha: 0.5),
//           Colors.transparent,
//         ],
//         stops: const [0.0, 0.5, 1.0],
//       ).createShader(
//         Rect.fromLTWH(centerX - 120, centerY - 2, 240, 4),
//       )
//       ..strokeWidth = 3
//       ..strokeCap = StrokeCap.round;

//     canvas.drawLine(
//       Offset(centerX - 100, centerY),
//       Offset(centerX + 20, centerY),
//       paint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant _CarTrailPainter oldDelegate) =>
//       oldDelegate.carPos != carPos;
// }

import 'package:flutter/material.dart';
import 'package:code_route_flutter/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);

    // Logo pop in
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Titre slide up
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
      ),
    );

    // Sous-titre
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    // Pulse cercle
    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mainController.forward();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (c, a, b) => const AuthWrapper(),
        transitionsBuilder: (c, a, b, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ));
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
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
          // Cercle décoratif haut gauche
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withValues(alpha: 0.06),
              ),
            ),
          ),

          // Cercle décoratif bas droite
          Positioned(
            bottom: -100,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E40AF).withValues(alpha: 0.05),
              ),
            ),
          ),

          // Contenu centré
          Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: isTablet ? 400 : double.infinity),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Logo ─────────────────────────────────────
                    AnimatedBuilder(
                      animation: Listenable.merge(
                          [_mainController, _pulseController]),
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: Transform.scale(
                              scale: _pulse.value,
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF3B82F6)
                                          .withValues(alpha: 0.18),
                                      blurRadius: 32,
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.directions_car_rounded,
                                        color: Color(0xFF1E40AF),
                                        size: 52,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 36),

                    // ── Titre ────────────────────────────────────
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _textSlide,
                        child: const Text(
                          'ELITE DRIVE',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: 5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Sous-titre ───────────────────────────────
                    FadeTransition(
                      opacity: _subtitleFade,
                      child: const Text(
                        'Le simulateur de conduite\nnouvelle génération',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Indicateur de chargement bas ─────────────────────
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _subtitleFade,
              child: Column(
                children: [
                  // Barre de progression animée
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: AnimatedBuilder(
                      animation: _mainController,
                      builder: (context, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _mainController.value,
                            backgroundColor:
                                const Color(0xFF3B82F6).withValues(alpha: 0.12),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF3B82F6),
                            ),
                            minHeight: 3,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Chargement...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFCBD5E1),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}